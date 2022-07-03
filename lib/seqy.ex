defmodule Seqy do
  @moduledoc """
  Before enqueueing events with Seqy, you need to define a handler for the topic.
  To define a handler, create a module that `use` the `Seqy.Handler` module. Then,
  implement the `handle/1` callback for each event you expect in the sequence.

  ```elixir
  defmodule MyApp.EventHandler do
    use Seqy.Handler

    require Logger

    def handle(%Seqy.Event{action: :"user.created", args: %{user_id: user_id}}) do
      Logger.info("\#{user_id} has been created.")
    end

    def handle(%Seqy.Event{action: :"user.purchased", args: %{user_id: user_id}}) do
      Logger.info("\#{user_id} has purchased an item.")
    end

    def handle(%Seqy.Event{action: :"user.paid", args: %{user_id: user_id}}) do
      Logger.info("\#{user_id} has paid.")
    end
  end
  ```

  With the event handler ready, we can start enqueueing events to Seqy.

  ```elixir
  %{action: :"user.created", queue_id: "user_id:1", topic: :user_purchase, args: %{user_id: 1}}
  |> Seqy.new()
  |> Seqy.enqueue()
  ```

  An event should have the ff:

  - `action` - event action that would be used for ordering
  - `queue_id` - this would be used as the routing key
  - `topic` - topic of the sequence you declared in your config
  - `args` - event payload
  """

  @topics Application.fetch_env!(:seqy, :topics)

  alias Seqy.Processbook
  alias Seqy.Event

  @doc """
  Returns a `Seqy.Event` struct.
  """
  @spec new(params :: map()) :: Event.t()
  def new(params) do
    %Event{
      id: params[:id] || UUID.uuid4(),
      action: params[:action],
      queue_id: params[:queue_id],
      topic: params[:topic],
      args: params[:args]
    }
  end

  @doc """
  Enqueues a new event for processing.
  """
  @spec enqueue(event :: Event.t()) :: :ok
  def enqueue(%Event{} = event) do
    do_enqueue(event)

    :ok
  end

  @doc """
  Enqueues a new event for processing and waits until the event gets processed or until
  the timeout lapses.
  """
  @spec enqueue_await(Seqy.Event.t(), timeout_in_ms :: pos_integer()) ::
          term() | {:error, :timeout}
  def enqueue_await(%Event{} = event, timeout_in_ms \\ 5_000) do
    do_enqueue(event, wait: true)

    receive do
      {:response, response} ->
        response
    after
      timeout_in_ms -> {:error, :timeout}
    end
  end

  defp do_enqueue(%Event{} = event, opts \\ []) do
    caller_pid = if opts[:wait], do: self()
    topic_config = get_topic_config(event.topic)

    case Processbook.get(event.topic, event.queue_id) do
      nil ->
        {:ok, queue_pid} =
          DynamicSupervisor.start_child(
            event.topic,
            {topic_config.handler, {event.topic, event.queue_id}}
          )

        Processbook.store(event.topic, event.queue_id, queue_pid)
        apply(topic_config.handler, :process, [queue_pid, event, caller_pid])

      queue_pid ->
        apply(topic_config.handler, :process, [queue_pid, event, caller_pid])
    end
  end

  defp get_topic_config(topic_name) do
    Enum.find(@topics, fn topic -> topic.name == topic_name end)
  end
end
