defmodule EctoJobScheduler.NewRelic.Reporter do
  @moduledoc false

  @callback start() :: term()

  @callback fail(pid(), map()) :: term()

  @callback add_attributes(keyword()) :: term()

  @callback complete(pid(), atom()) :: term()
end
