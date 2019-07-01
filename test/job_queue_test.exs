defmodule EctoJobScheduler.JobQueueTest do
  @moduledoc false
  use EctoJobScheduler.DataBase

  alias Ecto.Multi

  alias EctoJobScheduler.Logger.Context

  alias EctoJobScheduler.Test.TestJobQueue

  describe "perform/3" do
    test "execute and set context" do
      assert {:ok, %{test_job: :xablau}} ==
               TestJobQueue.perform(Multi.new(), %{
                 "type" => "TestJob",
                 "context" => %{some: :thing}
               })

      assert Context.get() == [params: %{"type" => "TestJob"}, some: :thing]
    end
  end
end
