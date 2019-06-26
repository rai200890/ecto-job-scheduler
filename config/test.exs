use Mix.Config

import System, only: [get_env: 1]
import String, only: [to_integer: 1]

config :ecto_job_scheduler, EctoJobScheduler.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: get_env("DATABASE_NAME") || "ecto_job_scheduler",
  username: get_env("DATABASE_USER") || "user",
  password: get_env("DATABASE_PASSWORD") || "pass",
  hostname: get_env("DATABASE_HOST") || "localhost",
  port: (get_env("DATABASE_PORT") || "5432") |> to_integer(),
  pool_size: (get_env("DATABASE_POOL_SIZE") || "10") |> to_integer(),
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/"

config :ecto_job_scheduler, ecto_repos: [EctoJobScheduler.Test.Repo]

config :ecto_job_scheduler, EctoJobScheduler.Test.TestJob, max_attempts: "5"

config :logger, level: :warn
