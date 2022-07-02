defmodule Seqy.Handler.Processor do
  @moduledoc false

  def process_event(%Seqy.Event{} = event, %{events: state_events} = state) do
    new_events = [event | state_events]

    do_process_event(%{state | events: new_events})
  end

  defp do_process_event(
         %{events: new_events, actions: [current_action | _], config: config} = state
       ) do
    case Enum.find(new_events, fn e -> e.action == current_action end) do
      nil ->
        {:noreply, %{state | events: new_events}}

      current_event ->
        apply(config.handler, :handle, [current_event])

        do_process_event(%{
          state
          | events: List.delete(new_events, current_event),
            actions: List.delete_at(state.actions, 0)
        })
    end
  end

  defp do_process_event(%{events: _, actions: []} = state), do: {:stop, :normal, state}
end
