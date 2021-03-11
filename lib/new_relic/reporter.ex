defmodule EctoJobScheduler.NewRelic.Reporter do
  @moduledoc false

  @callback fail(map()) :: term()
end
