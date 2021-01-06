defmodule EctoJobScheduler.NewRelic.JobInstrumenter do
  @moduledoc """
  Tool for capture metrics to NewRelic.
  """

  @doc """
  Execute a function and capture metrics to NewRelic from it.
  The metrics is grouped with name parameter.

  Example of use:

  NewRelic.JobInstrumenter.transaction("job/1", fn ->
    ...
  end)
  """
  @spec transaction(
          name :: String.t(),
          function :: (() -> {:error, term()} | any() | no_return())
        ) ::
          term()
  def transaction(name, function) do
    start()

    add_attributes(
      other_transaction_name: name,
      request_id: get_request_id()
    )

    case function.() do
      {:error, reason} ->
        {:current_stacktrace, stack} = Process.info(self(), :current_stacktrace)
        fail(:error, reason, stack)
        complete()
        {:error, reason}

      result ->
        complete()
        result
    end
  rescue
    exception ->
      fail(exception.__struct__, Exception.message(exception), __STACKTRACE__)
      complete()
      reraise exception, __STACKTRACE__
  end

  defp start, do: reporter().start()

  defp add_attributes(attributes) do
    reporter().add_attributes(attributes)
  end

  defp fail(kind, reason, stack) do
    reporter().fail(self(), %{
      kind: kind,
      reason: reason,
      stack: stack
    })
  end

  defp complete do
    transaction().stop_transaction()
  end

  defp get_request_id do
    Keyword.get(Logger.metadata(), :request_id)
  end

  defp transaction,
    do:
      Application.get_env(:ecto_job_scheduler, __MODULE__)[:transaction] ||
        NewRelic.Transaction

  defp reporter,
    do:
      Application.get_env(:ecto_job_scheduler, __MODULE__)[:reporter] ||
        NewRelic.Transaction.Reporter
end
