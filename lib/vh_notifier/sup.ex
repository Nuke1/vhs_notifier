defmodule Sup do
  use DynamicSupervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    :mnesia.create_table(Session, attributes: [:txid, :pid])
    :mnesia.add_table_index(Session, :txid)
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Store the processId of GenServer(Pending Transaction) in mnesia
  def open_session(txId, pid) do
    :mnesia.dirty_write({Session, txId, pid})
  end

  # Deletes th processId of GenServer(Completed/Invalid Transaction) in mnesia
  def close_session(txId) do
    :mnesia.dirty_delete({Session, txId})
  end

  # Adds a new GenServer process for pending transaction and stores the pid in mnesia. {true|false}
  def add_tx_process(txId) do
    val = :mnesia.transaction(fn -> :mnesia.match_object({Session, txId, :_}) end)

    case val do
      {:atomic, []} ->
        spec = {Server, txId}
        DynamicSupervisor.start_child(__MODULE__, spec)
        true

      _ ->
        false
    end
  end

  # Returns the pid of pending transaction. {empty|pid}
  def get_tx(txId) do
    case :mnesia.transaction(fn -> :mnesia.match_object({Session, txId, :_}) end) do
      {:atomic, []} -> :empty
      {:atomic, [{_, _, pid}]} -> pid
      _ -> :empty
    end
  end

  # Returns all pending transactions. {[Transaction hash list]|[]}
  def get_all_transactions() do
    case :mnesia.transaction(fn -> :mnesia.match_object({Session, :_, :_}) end) do
      {:atomic, []} ->
        []

      {:atomic, data} ->
        Enum.map(data, fn {_, tx, _} -> tx end)
    end
  end

  # Updates pending transaction status by making an ansynchronous call to GenServer process.
  def update_tx_status(txId, status) do
    case get_tx(txId) do
      :empty -> false
      pid -> GenServer.cast(pid, {:status, txId, status})
    end
  end
end
