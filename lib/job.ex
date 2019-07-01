defmodule EctoJobScheduler.Job do
  @moduledoc """
    Defines jobs to be used with EctoJobScheduler.JobQueue and EctoJobScheduler.JobScheduler
  """
  alias Ecto.Multi
  alias EctoJobScheduler.JobInfo

  @callback handle_job(%JobInfo{}, params :: map()) :: Multi.t()

  defmacro __using__(options \\ []) do
    quote do
      require Logger

      alias EctoJobScheduler.JobInfo
      alias EctoJobScheduler.Logger.Context

      @behaviour EctoJobScheduler.Job

      def perform(multi, params) do
        %JobInfo{max_attempts: max_attempts, attempt: attempt} = job_info = JobInfo.new(multi)

        {context, params} = Map.pop(params, "context", %{})

        job_context = %{
          "params" => params,
          "attempt" => attempt,
          "max_attempts" => max_attempts
        }

        Context.put(context)
        Context.put(job_context)

        Logger.info("Attempting to run #{inspect(__MODULE__)} #{attempt} out of #{max_attempts}")

        case job_info
             |> handle_job(params)
             |> config()[:repo].transaction() do
          {:ok, successful_changes} ->
            Logger.info("Successfully executed #{inspect(__MODULE__)}")

            {:ok, successful_changes}

          {:error, multi_identifier, reason, successful_changes} ->
            Logger.error("Unable to execute #{inspect(__MODULE__)}",
              multi_identifier: multi_identifier,
              error: inspect(reason)
            )

            {:error, multi_identifier, reason, successful_changes}
        end
      end

      def config do
        config = unquote(options)

        max_attempts =
          String.to_integer(Application.get_env(config[:otp_app], __MODULE__)[:max_attempts])

        Keyword.put(config, :max_attempts, max_attempts)
      end
    end
  end
end
