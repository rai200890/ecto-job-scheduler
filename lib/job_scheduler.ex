defmodule EctoJobScheduler.JobScheduler do
  @moduledoc """
  Defines scheduler for multiple EctoJobScheduler.Job
  """

  alias Ecto.Multi
  alias EctoJobScheduler.Logger.Context

  @spec schedule(
          Multi.t(),
          atom(),
          map(),
          keyword()
        ) :: Multi.t()
  def schedule(%Multi{} = multi, job, %{__struct__: _job_module} = params, config) do
    schedule(multi, job, cast_job_params(params), config)
  end

  def schedule(%Multi{} = multi, job, params, config) do
    context = Context.get() |> Enum.into(%{}) |> Map.drop([:params, "params"])
    params = Map.put_new(params, "context", context)

    type = job |> Atom.to_string() |> String.split(".") |> List.last()
    multi_name = type |> Macro.underscore() |> String.to_atom()

    multi
    |> config[:job_queue].enqueue(
      multi_name,
      Map.merge(%{"type" => type}, params),
      Keyword.merge(job.config(), config)
    )
  end

  @spec schedule(atom(), map(), keyword()) :: Multi.t()
  def schedule(job, params, config) do
    schedule(Multi.new(), job, params, config)
  end

  @spec schedule_many_jobs(
          Multi.t(),
          atom(),
          list(map()),
          keyword()
        ) :: Multi.t()
  def schedule_many_jobs(%Multi{} = multi, job, jobs_params, config) do
    type = job |> Atom.to_string() |> String.split(".") |> List.last()

    jobs =
      Enum.map(jobs_params, fn job ->
        context = Context.get() |> Enum.into(%{}) |> Map.drop([:params, "params"])

        params =
          job |> Map.put_new("context", context) |> cast_job_params() |> Map.put("type", type)

        now = NaiveDateTime.utc_now()
        %{params: params, inserted_at: now, updated_at: now}
      end)

    multi
    |> config[:job_queue]
    |> Multi.insert_all(:insert_all, config[:job_queue], jobs)
  end

  @spec schedule_many_jobs(
          atom(),
          list(map()),
          keyword()
        ) ::
          any()
  def schedule_many_jobs(job, jobs_params, config) do
    schedule_many_jobs(Multi.new(), job, jobs_params, config)
  end

  @spec run(atom(), map(), keyword()) :: {:error, any()} | {:ok, any()}
  def run(job, params, config) do
    multi = Multi.new() |> schedule(job, params, config)

    case config[:repo].transaction(multi) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec run_many_jobs(atom(), list(map()), keyword()) :: {:error, any()} | {:ok, any()}
  def run_many_jobs(job, jobs_params, config) do
    multi = Multi.new() |> schedule(job, jobs_params, config)

    case config[:repo].transaction(multi) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, reason}
    end
  end

  defp cast_job_params(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
  end

  defp cast_job_params(params) do
    params
  end

  def run(multi, config) do
    config[:repo].transaction(multi)
  end

  defmacro __using__(config \\ []) do
    quote do
      alias EctoJobScheduler.JobScheduler

      def config do
        unquote(config)
      end

      def schedule(multi, job, params, options \\ []) when is_map(params) do
        JobScheduler.schedule(multi, job, params, Keyword.merge(config(), options))
      end

      def schedule(job, params) do
        JobScheduler.schedule(job, params, config())
      end

      def schedule_many_jobs(job, jobs_params) do
        JobScheduler.schedule_many_jobs(job, jobs_params, config())
      end

      def run_many_jobs(job, params) when is_map(params) do
        JobScheduler.run(job, params, config())
      end

      def run(job, params, options \\ []) when is_map(params) do
        JobScheduler.run(job, params, Keyword.merge(config(), options))
      end

      def run(multi) do
        JobScheduler.run(multi, config())
      end

      def run(job, params) when is_map(params) do
        JobScheduler.run(job, params, config())
      end

      def run(job, params, options \\ []) when is_map(params) do
        JobScheduler.run(job, params, Keyword.merge(config(), options))
      end

      def run(multi) do
        JobScheduler.run(multi, config())
      end
    end
  end
end
