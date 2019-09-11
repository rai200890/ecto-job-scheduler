defmodule EctoJobScheduler.Test.TestJob do
  @moduledoc false

  use EctoJobScheduler.Job,
    repo: EctoJobScheduler.Test.Repo,
    otp_app: :ecto_job_scheduler

  alias Ecto.Multi

  def handle_job(%JobInfo{multi: multi}, _params),
    do: Multi.run(multi, :test_job, fn _, _ -> {:ok, :xablau} end)
end

defmodule EctoJobScheduler.Test.TestJobQueue do
  @moduledoc false
  use EctoJobScheduler.JobQueue,
    table_name: "test_jobs",
    jobs: [EctoJobScheduler.Test.TestJob]
end

defmodule EctoJobScheduler.Test.TestJobScheduler do
  @moduledoc false
  use EctoJobScheduler.JobScheduler,
    repo: EctoJobScheduler.Test.Repo,
    job_queue: EctoJobScheduler.Test.TestJobQueue
end

defmodule EctoJobScheduler.Test.TestJobParams do
  @moduledoc false
  defstruct [:some, :field]
end
