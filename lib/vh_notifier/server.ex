defmodule Server do
  use GenServer, restart: :temporary
	require Logger

  def start_link(txId) do
    GenServer.start_link(__MODULE__, txId)
  end

  ## Callbacks

  @impl true
  def init(txId) do
		Sup.open_session(txId, self())
		GenServer.cast(self(), {:add_tx, txId})
		{:ok, txId}
  end

  @impl true
  def handle_call(:status, _from, []) do
    {:reply, :ok, []}
  end

  @impl true
  def handle_cast({:add_tx, txId}, state) do
		val = :mnesia.dirty_read({Session, txId})
		api_prefix  = 'https://api.blocknative.com/transaction'
		api_key = "26d122b8-da8b-4adb-9e38-23015ad76bb4" #"58db358f-c479-46e8-9982-159eb9afc7e1"
		data = Jason.encode!(%{"apiKey" => api_key, "hash" => txId, "blockchain" => "ethereum", "network" => "main"})

		case :httpc.request(:post, {api_prefix, [], 'application/json', data}, [], []) do
			{:ok, {{_,400, _}, _res, _val}} -> {:stop, :normal, state}
			res ->
				send("Transaction: " <> txId <> "\nStatus: registered")
				Logger.info("res received #{inspect(res)}")
				{:noreply, state, 120000}
			end

  end

	def handle_cast({:status, txId, status}, state) do
		case status do
			"confirmed" ->
				send("Transaction: " <> txId <> "\nStatus: confirmed")
				{:stop, :normal, state}
			_ ->
				{:noreply, state}
		end
	end

	@impl true
	def handle_info(:timeout, state) do
		send("Transaction: " <> state <> "\nStatus: pending")
		{:noreply, state}
	end

	# Send transaction update to slack webhook
	def send(message) do
		slack_webhook = 'https://hooks.slack.com/services/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'
		data = Jason.encode!(%{"text" => message})
		:httpc.request(:post, {slack_webhook, [], 'application/json', data}, [], [])
  end

	def terminate(reason, state) do
    Sup.close_session(state)
    :normal
  end
end
