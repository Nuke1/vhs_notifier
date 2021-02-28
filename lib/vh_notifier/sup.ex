defmodule Sup do
	use DynamicSupervisor

	def start_link(_opts) do
		DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
	end

	# def open_session(txId, pid) do
	# 	:mnesia.dirty_write({Session, txId, pid})
	# end


	@impl true
	def init(_arg) do
		:mnesia.create_table(Session, attributes: [:txid, :pid])
		:mnesia.add_table_index(Session, :txid)
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end

  def add_tx_process(tx) do
		spec = {Server, [tx]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end


end
