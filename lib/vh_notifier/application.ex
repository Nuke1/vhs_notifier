defmodule VhNotifier.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    #:mnesia.create_schema([node()])
    :mnesia.start()
    :inets.start()
    :ssl.start()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VhNotifier.Supervisor]
    # Supervisor.start_link(children, opts)
    children = [
      # Starts a worker by calling: VhNotifier.Worker.start_link(arg)
      # {VhNotifier.Worker, arg}
      Sup,
      VhNotifier.Endpoint
    ]
    Supervisor.start_link(children, opts)

  end
end
