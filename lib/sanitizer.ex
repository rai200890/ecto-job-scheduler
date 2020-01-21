defmodule EctojobScheduler.Sanitizer do
  @callback to_log(map() | any()) :: map() | any()
end
