use Mix.Config

config :vh_notifier, VhNotifier.Endpoint, port: 4000
config :vh_notifier, redirect_url: "http://localhost:4000/"

import_config "#{Mix.env()}.exs"
