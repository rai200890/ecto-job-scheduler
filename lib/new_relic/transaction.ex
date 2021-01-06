defmodule EctoJobScheduler.NewRelic.TransactionBehaviour do
  @moduledoc false

  @callback stop_transaction() :: :ok
end
