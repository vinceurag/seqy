defmodule Seqy.Handler do
  @moduledoc """
  Use this module to define a handler.

  A handler should implement the `handle/1` callback.
  """

  @callback handle(event :: %Seqy.Event{}) :: any()

  defmacro __using__(_opts) do
    quote do
      use GenServer

      alias Seqy.Handler.Processor
      alias Seqy.Processbook

      def init({topic_name, queue_id}) do
        config =
          Application.fetch_env!(:seqy, :topics)
          |> Enum.find(fn topic -> topic.name == topic_name end)
          |> Map.put(:queue_id, queue_id)

        {:ok, %{events: [], actions: config.actions, config: config}}
      end

      def start_link({topic_name, queue_id}) do
        GenServer.start_link(__MODULE__, {topic_name, queue_id})
      end

      def process(pid, %Seqy.Event{} = event) do
        GenServer.cast(pid, {:process_event, event})
      end

      def handle_cast(
            {:process_event, %Seqy.Event{} = event},
            %{actions: actions} = state
          ) do
        case List.first(actions) do
          nil ->
            {:stop, :normal, state}

          _current_action ->
            Processor.process_event(event, state)
        end
      end

      def terminate(_reason, %{config: config}) do
        Processbook.delete(config.name, config.queue_id)

        :ok
      end
    end
  end
end
