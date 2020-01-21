defmodule EctoJobScheduler.SimpleSanitizer do
  @moduledoc """
    Sanitize maps
  """
  @behaviour EctojobScheduler.Sanitizer

  @impl Sanitizer
  def to_log(%{} = map) do
    map
    |> Map.drop(get_keys())
  end

  def to_log(other), do: other

  defp get_keys do
    Application.get_env(:ecto_job_scheduler, __MODULE__)[:keys]
  end
end
