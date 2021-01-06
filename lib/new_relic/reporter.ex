defmodule EctoJobScheduler.NewRelic.Reporter do
  @moduledoc false

  @callback start_transaction(:other) :: term()

  @callback stop_transaction(:other) :: term()

  @callback add_attributes(keyword()) :: term()

  @callback fail(map()) :: term()
end
