defmodule EctoJobScheduler.Test.SimpleSanitizerTest do

  use ExUnit.Case

  alias EctoJobScheduler.SimpleSanitizer

  describe "to_log/1" do
    test "When map are given, should remove given keys" do
      to_log_test = %{
        "xablau" => 12,
        "gokou" => "there",
        "mestrinha" => "Rai00",
        "cpf" => "123"
      }

      assert SimpleSanitizer.to_log(to_log_test) == %{"mestrinha" => "Rai00"}
    end
  end
end
