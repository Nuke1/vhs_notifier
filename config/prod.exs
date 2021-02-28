use Mix.Config

config :vh_notifier, VhNotifier.Endpoint,
  port: String.to_integer(System.get_env("PORT") || "4444")

config :vh_notifier, redirect_url: System.get_env("REDIRECT_URL")
