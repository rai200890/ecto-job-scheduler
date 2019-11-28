defmodule EctoJobScheduler.Test.EctoJobHelpers do
  @moduledoc false

  import ExUnit.Assertions
  import EctoJob.JobQueue
  import Ecto.Query, only: [from: 2]

  @default_options [
    attempt: 0,
    max_attempts: 5
  ]

  @spec build_initial_multi(
          repo :: atom,
          job_queue :: atom,
          job_args :: map(),
          options :: keyword
        ) ::
          Ecto.Multi.t()
  def build_initial_multi(repo, job_queue, job_args, options \\ []) do
    merged_options = Keyword.merge(@default_options, options)
    job = job_queue.new(job_args, max_attempts: Keyword.get(merged_options, :max_attempts))
    job = %{job | attempt: Keyword.get(merged_options, :attempt)}
    job = repo.insert!(job)
    initial_multi(job)
  end

  @spec dispatch_job(
          repo :: atom,
          job_queue :: atom,
          job_args :: map()
        ) :: any
  def dispatch_job(repo, job_queue, job) do
    job = update_job(repo, job_queue, job)
    job |> initial_multi() |> job_queue.perform(job.params)
  end

  @spec assert_job_executed_successfully(
          repo :: atom,
          job_queue :: atom,
          job_args :: map()
        ) ::
          boolean
  def assert_job_executed_successfully(repo, job_queue, job) do
    job = update_job(repo, job_queue, job)
    job |> initial_multi() |> job_queue.perform(job.params)
    assert job_queue |> repo.get(job.id) |> is_nil()
  end

  defp update_job(repo, job_queue, job) do
    case repo.update_all(
           from(
             j in job_queue,
             where: j.id == ^job.id
           ),
           set: [
             attempt: job.attempt + 1,
             state: "IN_PROGRESS",
             updated_at: DateTime.utc_now()
           ]
         ) do
      {0, _} -> nil
      {1, _} -> repo.get(job_queue, job.id)
    end
  end

  defmacro assert_has_job(repo, job_queue, match) do
    quote do
      unquote(job_queue)
      |> unquote(repo).all()
      |> Enum.find(fn job ->
        match?(unquote(match), job.params)
      end)
      |> case do
        nil ->
          flunk("Could not find a matching Job")

        job ->
          job
      end
    end
  end
end
