defmodule Seqy.Support.FakeHandler do
  @moduledoc false
  use Seqy.Handler

  def handle(%Seqy.Event{action: action}) do
    test_process = Process.whereis(:test_process)
    send(test_process, action)
  end
end
