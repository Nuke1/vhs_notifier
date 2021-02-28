defmodule Sup do
	use DynamicSupervisor

	def start_link(_opts) do
		DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
	end

	@impl true
	def init(_arg) do
		:mnesia.create_table(Session, attributes: [:txid, :pid])
		:mnesia.add_table_index(Session, :txid)
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end

	def open_session(txId, pid) do
		:mnesia.dirty_write({Session, txId, pid})
  end

	def close_session(txId) do
		:mnesia.dirty_delete({Session, txId})
	end

  def add_tx_process(txId) do
		val = :mnesia.transaction(fn -> :mnesia.match_object({Session, txId, :_}) end)
		case val do
			{:atomic, []} ->
				spec = {Server, txId}
   		 	DynamicSupervisor.start_child(__MODULE__, spec)
				:true
			_ ->
				:false
	 end
	end


	def get_tx(txId) do
		case :mnesia.transaction(fn -> :mnesia.match_object({Session, txId, :_}) end) do
			{:atomic, []} -> :empty
			{:atomic, [{_,_,pid}]} -> pid
			_ -> :empty
		end
	end

	def get_all_transactions() do
		:mnesia.transaction(fn -> :mnesia.match_object({Session, :_, :_}) end)
	end

	def update_tx_status(txId, status) do
		case get_tx(txId) do
			:empty -> :false
			pid -> GenServer.cast(pid, {:status, txId,status})
		end
	end

end
