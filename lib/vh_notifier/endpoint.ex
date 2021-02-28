# defmodule Endpoint do
#   use Plug.Router
#   use Plug.Debugger
#   use Plug.ErrorHandler
#   require Logger
#   def child_spec(opts) do
#     %{
#       id: __MODULE__,
#       start: {__MODULE__, :start_link, [opts]}
#     }
#   end

#   # def start_link(_opts) do
#   #    Plug.Adapters.Cowboy2.http(__MODULE__, [])
#   # end
#   def start_link(_opts) do
#     with {:ok, [port: port] = config} <- Application.fetch_env(:vh_notifier, __MODULE__) do
#       Logger.info("Starting server at http://localhost:#{port}/")
#       Plug.Adapters.Cowboy2.http(__MODULE__, [], config)
#     end
#   end

#   plug(:match)

#   plug(Plug.Parsers,
#     parsers: [:json],
#     pass: ["application/json"],
#     json_decoder: {Jason, :decode!, [[keys: :atoms]]}

#   )

#   plug(:dispatch)

#   get "/" do
# 		send_resp(conn, 200, "Hello There!")
# 	end

#   match _ do
#     send_resp(conn, 404, "Requested page not found!")
#   end


# #   use Plug.Router
# #   require Logger

# # 	plug :match
# # 	plug :dispatch
# # 	plug Plug.Static, at: "/home", from: :server
# #   plug(Plug.Parsers,
# #     parsers: [:json],
# #     pass: ["application/json"],
# #     json_decoder: Jason
# #   )

# #   def child_spec(opts) do
# #     %{
# #       id: __MODULE__,
# #       start: {__MODULE__, :start_link, [opts]}
# #     }
# #   end

# #   def start_link(_opts) do
# #     with {:ok, [port: port] = config} <- Application.fetch_env(:vh_notifier, __MODULE__) do
# #       Logger.info("Starting server at http://localhost:#{port}/")
# #       Plug.Adapters.Cowboy2.http(__MODULE__, [], config)
# #     end
# #   end

# # 	get "/" do
# # 		send_resp(conn, 200, "Hello There!")
# # 	end

# # 	get "/about/:user_name" do
# # 		send_resp(conn, 200, "Hello, #{user_name}")
# # 	end

# # 	get "/home" do
# # 		conn = put_resp_content_type(conn, "text/html")
# # 		send_file(conn, 200, "lib/index.html")
# # 	end

# #   post "/webhook" do
# #     # IO.inspect(conn.params, label: "The params")
# #     {:ok, data, _conn} = read_body(conn)
# #     Logger.info("data #{inspect(data)}")
# #     send_resp(conn, 200, "Got it #{data}")
# #   end


# # 	match _, do: send_resp(conn, 404, "404 error not found!")

# # end
# end

defmodule VhNotifier.Endpoint do
  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler
  require Logger
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  # def start_link(_opts) do
  #    Plug.Adapters.Cowboy2.http(__MODULE__, [])
  # end
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
  #   json_decoder:  Poison
  # )

  plug(:dispatch)


  get "/" do
		send_resp(conn, 200, "Hello There!")
	end

  post "/webhook" do
    # IO.inspect(conn.params, label: "The params")
    {:ok, data, _conn} = read_body(conn)
    Logger.info("data #{inspect(data)}")
    send_resp(conn, 200, "Got it #{data}")
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
end
