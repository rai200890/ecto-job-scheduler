defmodule EctoJobScheduler.Test.Repo do
  @moduledoc false
  use Ecto.Repo, otp_app: :ecto_job_scheduler, adapter: Ecto.Adapters.Postgres
end
