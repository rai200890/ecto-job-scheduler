use Mix.Config

config :ecto_job_scheduler, EctoJobScheduler.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/"

config :ecto_job_scheduler, ecto_repos: [EctoJobScheduler.Test.Repo]

config :ecto_job_scheduler, EctoJobScheduler.Test.TestJob, max_attempts: "15"

config :logger, level: :warn
