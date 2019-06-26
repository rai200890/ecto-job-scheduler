defmodule EctoJobScheduler.JobQueue do
  @moduledoc false

  defmacro __using__(table_name: table_name, jobs: jobs) do
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
