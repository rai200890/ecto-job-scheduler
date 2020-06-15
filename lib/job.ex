defmodule EctoJobScheduler.Job do
  @moduledoc """
  Defines jobs to be used with EctoJobScheduler.JobQueue and EctoJobScheduler.JobScheduler.
  """

  alias EctoJobScheduler.JobInfo

  require Logger

  @callback handle_job(%JobInfo{}, params :: map()) :: any()

  def handle_job_result(result, original_multi, repo) do
    case result do
      %Ecto.Multi{} = multi ->
        repo.transaction(multi)

      :ok ->
        repo.transaction(original_multi)
        :ok

      {:ok, result} ->
        repo.transaction(original_multi)
        {:ok, result}

      other ->
        other
    end
  end

  def handle_job_result(:ok, job_name) do
    Logger.info("Successfully executed #{job_name}")

    {:ok, :ok}
  end

  def handle_job_result({:ok, successful_changes}, job_name) do
    Logger.info("Successfully executed #{job_name}")

    {:ok, successful_changes}
  end

  def handle_job_result({:error, multi_identifier, reason, successful_changes}, job_name) do
    Logger.error("Unable to execute #{job_name}",
      multi_identifier: multi_identifier,
      error: inspect(reason)
    )

    {:error, multi_identifier, reason, successful_changes}
  end

  def handle_job_result({:error, reason}, job_name) do
    Logger.error("Unable to execute #{job_name}", error: inspect(reason))

    {:error, reason}
  end

  defmacro __using__(options \\ []) do
    quote do
      require Logger

      alias EctoJobScheduler.JobInfo
      alias EctoJobScheduler.Logger.Context
      alias EctoJobScheduler.SimpleSanitizer

      @behaviour EctoJobScheduler.Job

      @default_options [max_attempts: 5]

      def perform(multi, params) do
        Context.reset()
        %JobInfo{max_attempts: max_attempts, attempt: attempt} = job_info = JobInfo.new(multi)

        {context, params} = Map.pop(params, "context", %{})

        job_context = %{
          "params" => sanitize(params),
          "attempt" => attempt,
          "max_attempts" => max_attempts
        }

        Context.put(context)

        Context.put(job_context)

        job_name = inspect(__MODULE__)

        Logger.info("Attempting to run #{job_name} #{attempt} out of #{max_attempts}")

        job_info |> run_job(params) |> EctoJobScheduler.Job.handle_job_result(job_name)
      end

      defp run_job(%JobInfo{multi: original_multi} = job_info, params) do
        job_info
        |> handle_job(params)
        |> EctoJobScheduler.Job.handle_job_result(original_multi, config()[:repo])
      end

      defp sanitizer do
        Application.get_env(:ecto_job_scheduler, :sanitizer, fn param -> param end)
      end

      defp sanitize(params) do
        case sanitizer() do
          fun when is_function(fun) -> fun.(params)
          {mod, fun_name} -> apply(mod, fun_name, [params])
        end
      end

      def config do
        merged_options =
          @default_options
          |> Keyword.merge(unquote(options))
          |> Keyword.merge(Application.get_env(unquote(options)[:otp_app], __MODULE__) || [])

        max_attempts =
          case merged_options[:max_attempts] do
            max_attempts when is_integer(max_attempts) -> max_attempts
            max_attempts -> String.to_integer(max_attempts)
          end

        Keyword.put(merged_options, :max_attempts, max_attempts)
      end
    end
  end
end
