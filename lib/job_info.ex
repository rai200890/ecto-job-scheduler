defmodule EctoJobScheduler.JobInfo do
  @moduledoc """
  Metadata about EctoJob
  """
  alias Ecto.{Changeset, Multi}

  defstruct [:multi, :job_queue, :attempt, :max_attempts]

  @type t :: %__MODULE__{
          multi: Ecto.Multi.t(),
          job_queue: any(),
          attempt: integer(),
          max_attempts: integer()
        }

  @spec new(Ecto.Multi.t()) :: __MODULE__.t()
  def new(multi) do
    case multi |> Multi.to_list() |> List.first() do
      {_job_name, {:delete, %Changeset{data: job_queue}, _options}} ->
        %__MODULE__{
          job_queue: job_queue,
          multi: multi,
          attempt: job_queue.attempt,
          max_attempts: job_queue.max_attempts
        }

      _ ->
        %__MODULE__{multi: multi}
    end
  end
end
