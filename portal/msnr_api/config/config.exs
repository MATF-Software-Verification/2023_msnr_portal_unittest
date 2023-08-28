# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :msnr_api,
  ecto_repos: [MsnrApi.Repo],
  # 7 dana
  refresh_token_expiration: 604_800,
  # 30 minuta
  access_token_expiration: 1800,
  documents_store: "/Users/nemanja/master/novi/msnr_api/files"

# Configures the endpoint
config :msnr_api, MsnrApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MsnrApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MsnrApi.PubSub,
  live_view: [signing_salt: "a0se2qS7"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :msnr_api, MsnrApi.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: ["http://localhost:8080"],
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
