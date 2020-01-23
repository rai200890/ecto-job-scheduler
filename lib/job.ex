defmodule EctoJobScheduler.Job do
  @moduledoc """
    Defines jobs to be used with EctoJobScheduler.JobQueue and EctoJobScheduler.JobScheduler
  """
  alias EctoJobScheduler.JobInfo

  @callback handle_job(%JobInfo{}, params :: map()) :: any()

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

        Logger.info("Attempting to run #{inspect(__MODULE__)} #{attempt} out of #{max_attempts}")

        case run_job(job_info, params) do
          :ok ->
            Logger.info("Successfully executed #{inspect(__MODULE__)}")
            :ok

          {:ok, successful_changes} ->
            Logger.info("Successfully executed #{inspect(__MODULE__)}")

            {:ok, successful_changes}

          {:error, multi_identifier, reason, successful_changes} ->
            Logger.error("Unable to execute #{inspect(__MODULE__)}",
              multi_identifier: multi_identifier,
              error: inspect(reason)
            )

            {:error, multi_identifier, reason, successful_changes}

          {:error, reason} ->
            Logger.error("Unable to execute #{inspect(__MODULE__)}",
              error: inspect(reason)
            )

            {:error, reason}
        end
      end

      defp run_job(%JobInfo{multi: original_multi} = job_info, params) do
        case handle_job(job_info, params) do
          %Ecto.Multi{} = multi ->
            config()[:repo].transaction(multi)

          result ->
            handle_job_result(original_multi, result)
        end
      end

      defp handle_job_result(original_multi, result) do
        case result do
          :ok ->
            config()[:repo].transaction(original_multi)
            :ok

          {:ok, result} ->
            config()[:repo].transaction(original_multi)
            {:ok, result}

          other ->
            other
        end
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
