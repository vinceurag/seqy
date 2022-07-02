defmodule Seqy.Event do
  @type t() :: %__MODULE__{
          id: String.t(),
          action: atom(),
          queue_id: term(),
          topic: atom(),
          args: term()
        }

  defstruct [:id, :action, :queue_id, :topic, :args]
end
