defmodule EctoJobScheduler.JobScheduler do
  @moduledoc """
  Defines scheduler for multiple EctoJobScheduler.Job
  """

  alias Ecto.Multi
  alias EctoJobScheduler.Logger.Context

  @spec schedule(
          Ecto.Multi.t(),
          atom(),
          map(),
          nil | keyword() | map()
        ) :: any()
  def schedule(%Multi{} = multi, job, %{__struct__: _job_module} = params, config) do
    params =
      params
      |> Map.from_struct()
      |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)

    schedule(multi, job, params, config)
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
      config
    )
  end

  @spec schedule(atom() | %{config: nil | keyword() | map()}, map(), nil | keyword() | map()) ::
          any()
  def schedule(job, params, config) do
    schedule(Multi.new(), job, params, config)
  end

  @spec run(atom(), map(), nil | [repo: atom, job_queue: atom]) :: {:error, any()} | {:ok, any()}
  def run(job, params, config) do
    multi = Multi.new() |> schedule(job, params, config)

    case config[:repo].transaction(multi) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, reason}
    end
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
