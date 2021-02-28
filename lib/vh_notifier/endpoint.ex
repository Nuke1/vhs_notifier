defmodule VhNotifier.Endpoint do
  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler
  import Plug.Conn
  require Logger
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    with {:ok, [port: port] = config} <- Application.fetch_env(:vh_notifier, __MODULE__) do
      Logger.info("Starting server at http://localhost:#{port}/")
      Plug.Adapters.Cowboy2.http(__MODULE__, [], config)
    end
  end

  plug(:match)

  # plug(Plug.Parsers,
  #   parsers: [:json],
  #   pass: ["application/json"],
  #   json_decoder: Poison
  # )

  plug(:dispatch)


  get "/" do
		send_resp(conn, 200, "Hello There!")
	end

  get "/addtx/" do
    conn = fetch_query_params(conn)
    %{"id" => txId} = conn.params
    ret = Sup.add_tx_process(txId)
    Logger.info("data #{inspect(txId)}")
    case ret do
      :true ->  send_resp(conn, 200, "Transaction added successfully !")
      _ -> send_resp(conn, 200, "Transaction already exists !")
    end
  end

  get "/alltx" do
    list = Sup.get_all_transactions()
    send_resp(conn, 200, Jason.encode!(list))
  end

  post "/webhook" do
    {:ok, body, _conn} = read_body(conn)
    try do
      Logger.info("data #{inspect(body)}")
      {:ok,data} = Jason.decode(body)
        txId = data["hash"]
        status = data["status"]
        case status do
          "pending" ->  :ok
          _ ->  Sup.update_tx_status(txId, status)
        end
        Logger.info("data #{inspect(data)}")
        send_resp(conn, 200, "Got it #{data}")
    rescue error ->
      send_resp(conn, 200, "Invalid ")
    end

  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
end
