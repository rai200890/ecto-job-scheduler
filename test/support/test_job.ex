defmodule EctoJobScheduler.Test.TestJob do
  @moduledoc false
  use EctoJobScheduler.Job,
    repo: EctoJobScheduler.Test.Repo,
    otp_app: :ecto_job_scheduler

  def handle_job(%JobInfo{multi: multi}, _params),
    do: Ecto.Multi.run(multi, :test_job, fn _, _ -> {:ok, :xablau} end)
end

defmodule EctoJobScheduler.Test.TestJobError do
  @moduledoc false
  use EctoJobScheduler.Job,
    repo: EctoJobScheduler.Test.Repo,
    otp_app: :ecto_job_scheduler

  def handle_job(%JobInfo{multi: multi}, _params),
    do: Ecto.Multi.run(multi, :test_job, fn _, _ -> {:error, :xablau} end)
end

defmodule EctoJobScheduler.Test.TestJobNotMultiSuccessful do
  @moduledoc false
  use EctoJobScheduler.Job,
    repo: EctoJobScheduler.Test.Repo,
    otp_app: :ecto_job_scheduler

  def handle_job(%JobInfo{multi: _multi}, _params) do
    {:ok, :xablau}
  end
end

defmodule EctoJobScheduler.Test.TestJobNotMultiError do
  @moduledoc false
  use EctoJobScheduler.Job,
    repo: EctoJobScheduler.Test.Repo,
    otp_app: :ecto_job_scheduler

  def handle_job(%JobInfo{multi: _multi}, _params) do
    {:error, :sad_keanu}
  end
end

defmodule EctoJobScheduler.Test.TestJobException do
  @moduledoc false
  use EctoJobScheduler.Job,
    repo: EctoJobScheduler.Test.Repo,
    otp_app: :ecto_job_scheduler

  def handle_job(%JobInfo{multi: _multi}, _params) do
    raise "Xablau!"
  end
end

defmodule EctoJobScheduler.Test.TestJobQueue do
  @moduledoc false
  use EctoJobScheduler.JobQueue,
    table_name: "test_jobs",
    jobs: [
      EctoJobScheduler.Test.TestJob,
      EctoJobScheduler.Test.TestJobError,
      EctoJobScheduler.Test.TestJobNotMultiSuccessful,
      EctoJobScheduler.Test.TestJobNotMultiError,
      EctoJobScheduler.Test.TestJobException
    ],
    max_attempts: "5"
end

defmodule EctoJobScheduler.Test.TestJobQueueNewRelic do
  @moduledoc false
  use EctoJobScheduler.JobQueue,
    table_name: "test_jobs",
    jobs: [
      EctoJobScheduler.Test.TestJob,
      EctoJobScheduler.Test.TestJobError,
      EctoJobScheduler.Test.TestJobNotMultiSuccessful,
      EctoJobScheduler.Test.TestJobNotMultiError,
      EctoJobScheduler.Test.TestJobException
    ],
    max_attempts: "5",
    instrumenter: :new_relic
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
