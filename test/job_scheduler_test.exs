defmodule EctoJobScheduler.JobSchedulerTest do
  @moduledoc false
  use ExUnit.Case

  alias Ecto.{Changeset, Multi}
  alias EctoJobScheduler.Logger.Context
  alias EctoJobScheduler.Test.TestJobScheduler
  alias EctoJobScheduler.Test.TestJob

  describe "schedule/3" do
    test "put context as an ecto job param" do
      params = %{"data" => "any"}
      metadata = [some: :thing]
      Context.put(metadata)
      expected_context = metadata |> Enum.into(%{})

      assert %Multi{
               operations: [
                 test_job:
                   {:changeset,
                    %Changeset{
                      action: :insert,
                      valid?: true,
                      data: %{
                        params: %{"context" => result_context, "data" => "any"}
                      }
                    }, []}
               ]
             } = TestJobScheduler.schedule(Multi.new(), TestJob, params)

      assert expected_context == result_context
    end

    test "remove context from params before publishing it as an ecto job param" do
      metadata = [some: :thing]
      params = %{"data" => "any"}
      Context.put(params: %{}, some: :thing)
      expected_context = metadata |> Enum.into(%{})

      assert %Multi{
               operations: [
                 test_job:
                   {:changeset,
                    %Changeset{
                      action: :insert,
                      valid?: true,
                      data: %{
                        params: %{"context" => result_context, "data" => "any"}
                      }
                    }, []}
               ]
             } = TestJobScheduler.schedule(Multi.new(), TestJob, params)

      assert expected_context == result_context
    end
  end
end
