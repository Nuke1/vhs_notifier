defmodule Server do
  use GenServer
	require Logger
	require Sup

	_api_prefix = "https://api.blocknative.com/transaction"
  _api_key = "58db358f-c479-46e8-9982-159eb9afc7e1"

  def start_link(txId) do
    GenServer.start_link(__MODULE__, [txId])
  end

  ## Callbacks

  @impl true
  def init(txId) do
		:mnesia.dirty_write({Session, txId, self()})
		# val = :mnesia.dirty_read({Session, txId})
		# Logger.info("Value: #{inspect(val)}")
		GenServer.cast(self(), {:add_tx, txId})
		{:ok, txId}
  end

  @impl true
  def handle_call(:status, _from, []) do
    {:reply, :ok, []}
  end

  @impl true
  def handle_cast({:add_tx, _txId}, state) do
		api_prefix  = 'https://api.blocknative.com/transaction'
		api_key = "58db358f-c479-46e8-9982-159eb9afc7e1"
		hash  = "0xea8ab365a8750b64208d595d80a53a71d0e37dff538ae47184dc0337dd917c33"
		data = Jason.encode!(%{"apiKey" => api_key, "hash" => hash, "blockchain" => "ethereum", "network" => "main"})
		Req = :httpc.request(:post, {api_prefix, [], 'application/json', data}, [], [])
    {:noreply, state, 1000}
  end

	@impl true
	def handle_info(:timeout, state) do

		{:noreply, state}
	end

	# Send transaction update to slack webhook
	def send(message) do
		slack_webhook = 'https://hooks.slack.com/services/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'
		data = Jason.encode!(%{"text" => message})
		Req = :httpc.request(:post, {slack_webhook, [], 'application/json', data}, [], [])
  end

end
