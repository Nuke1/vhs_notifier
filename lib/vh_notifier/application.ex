defmodule VhNotifier.Application do

  use Application

  def start(_type, _args) do

    :mnesia.start()
    :inets.start()
    :ssl.start()
    opts = [strategy: :one_for_one, name: VhNotifier.Supervisor]
    children = [
      Sup,
      VhNotifier.Endpoint
    ]
    Supervisor.start_link(children, opts)

  end
end
