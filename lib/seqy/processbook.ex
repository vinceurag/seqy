defmodule Seqy.Processbook do
  use GenServer

  def init(_args) do
    :ets.new(:seqy_processbook, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])

    {:ok, []}
  end

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def store(topic, queue_id, pid) do
    :ets.insert(:seqy_processbook, {{topic, queue_id}, pid})
  end

  def get(topic, queue_id) do
    case :ets.lookup(:seqy_processbook, {topic, queue_id}) do
      [] ->
        nil

      [{_key, pid}] ->
        pid
    end
  end

  def delete(topic, queue_id) do
    :ets.delete(:seqy_processbook, {topic, queue_id})
  end
end
