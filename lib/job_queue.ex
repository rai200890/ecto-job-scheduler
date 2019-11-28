defmodule EctoJobScheduler.JobQueue do
  @moduledoc """
   Defines EctoJob.JobQueue based on defined EctoJobScheduler.Job
  """

  defmacro __using__(options \\ []) do
    table_name = options[:table_name]
    jobs = options[:jobs]

    quote bind_quoted: [table_name: table_name, jobs: jobs] do
      use EctoJob.JobQueue, table_name: table_name
      require Logger

      alias Ecto.Multi

      Enum.each(jobs, fn job ->
        type = job |> Atom.to_string() |> String.split(".") |> List.last()

        def perform(%Multi{} = multi, %{"type" => unquote(type)} = job_params) do
          apply(unquote(job), :perform, [multi, job_params])
        end
      end)
    end
  end
end
