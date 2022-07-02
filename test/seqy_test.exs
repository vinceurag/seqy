defmodule SeqyTest do
  use ExUnit.Case

  describe "enqueue/1" do
    setup do
      Process.register(self(), :test_process)

      on_exit(fn ->
        if :test_process in Process.registered(), do: Process.unregister(:test_process)
      end)

      {:ok, test_pid: self()}
    end

    test "processes the events sequentially" do
      %{action: uc_action} = user_created_event = fixture(:user_created)
      %{action: upurchased_action} = user_purchased_event = fixture(:user_purchased)
      %{action: upaid_action} = user_paid_event = fixture(:user_paid)

      Seqy.enqueue(user_paid_event)
      refute_receive ^upaid_action

      Seqy.enqueue(user_purchased_event)
      refute_receive ^upurchased_action

      Seqy.enqueue(user_created_event)
      assert_receive ^uc_action
      assert_receive ^upurchased_action
      assert_receive ^upaid_action
    end
  end

  defp fixture(:user_created) do
    %{action: :"user.created", queue_id: "test", topic: :user_purchase, args: "hello"}
    |> Seqy.new()
  end

  defp fixture(:user_purchased) do
    %{action: :"user.purchased", queue_id: "test", topic: :user_purchase, args: "hello"}
    |> Seqy.new()
  end

  defp fixture(:user_paid) do
    %{action: :"user.paid", queue_id: "test", topic: :user_purchase, args: "hello"}
    |> Seqy.new()
  end
end
