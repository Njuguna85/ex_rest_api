# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :real_deal_api,
  ecto_repos: [RealDealApi.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :real_deal_api, RealDealApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: RealDealApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RealDealApi.PubSub,
  live_view: [signing_salt: "e3dmCsTx"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian.DB,
  # Add your repository module
  repo: RealDealApi.Repo,
  # default
  schema_name: "guardian_tokens",
  # store all token types if not set
  token_types: ["refresh_token"],
  # default: 60 minutes
  sweep_interval: 60

alias RealDealApiWeb.Auth.Guardian

config :real_deal_api, Guardian,
  issuer: "real_deal_api",
  secret_key: "PJRFT7I9OuKZfQyrj9bCSEerHwqqss+EsVZhlMhsJUYgYQwfa+qp6w4svHOla/Pl"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
