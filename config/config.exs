import Config

config :logger,
  level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id, :tx_id]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id, :tx_id]

# Import environment specific config
import_config "#{Mix.env()}.exs"