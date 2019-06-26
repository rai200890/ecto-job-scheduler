defmodule EctoJobScheduler.Test.Repo do
  use Ecto.Repo, otp_app: :ecto_job_scheduler, adapter: Ecto.Adapters.Postgres
end
