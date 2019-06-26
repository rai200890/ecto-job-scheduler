defmodule EctoJobScheduler.Support.Helpers.EctoJobHelpers do
  @moduledoc false
  alias EctoJobScheduler.Test.Repo
  alias EctoJobScheduler.JobQueue

  import ExUnit.Assertions
  import EctoJob.JobQueue

  @default_options [
    attempt: 0,
    max_attempts: 5
  ]

  @spec build_initial_multi(JobQueue.t(), map(), keyword()) :: Ecto.Multi.t()
  def build_initial_multi(job_queue, job_args, options \\ []) do
    merged_options = Keyword.merge(@default_options, options)
    job = job_queue.new(job_args, max_attempts: Keyword.get(merged_options, :max_attempts))
    job = %{job | attempt: Keyword.get(merged_options, :attempt)}
    job = Repo.insert!(job)
    initial_multi(job)
  end

  @spec dispatch_job(JobQueue.t(), JobQueue.t()) :: list({:ok, any()} | {:error, any()})
  def dispatch_job(job_queue, job) do
    result = job |> initial_multi() |> job_queue.perform(job.params)
    update_job!(job_queue, job)
    result
  end

  @spec assert_job_executed_successfully(JobQueue.t(), JobQueue.t()) :: boolean()
  def assert_job_executed_successfully(job_queue, job) do
    job |> initial_multi() |> job_queue.perform(job.params)
    assert job_queue |> Repo.get(job.id) |> is_nil()
  end

  defp update_job!(job_queue, job) do
    case Repo.get(job_queue, job.id) do
      nil ->
        nil

      job ->
        %{job | updated_at: NaiveDateTime.utc_now()} |> delete_job_changeset() |> Repo.update!()
    end
  end
end
