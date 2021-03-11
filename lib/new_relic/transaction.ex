defmodule EctoJobScheduler.NewRelic.TransactionBehaviour do
  @moduledoc false

  @callback stop_transaction() :: :ok

  @callback add_attributes(list()) :: :ok

  @callback start_transaction(String.t(), String.t()) :: :ok
end
