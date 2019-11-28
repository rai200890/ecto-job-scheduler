defmodule EctoJobScheduler.JobSchedulerTest do
  @moduledoc false
  use ExUnit.Case

  alias Ecto.{Changeset, Multi}
  alias EctoJobScheduler.Logger.Context

  alias EctoJobScheduler.Test.{
    TestJob,
    TestJobParams,
    TestJobScheduler
  }

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
                      data: job
                    }, []}
               ]
             } = TestJobScheduler.schedule(Multi.new(), TestJob, params)

      assert %EctoJobScheduler.Test.TestJobQueue{
               params: %{"context" => result_context, "data" => "any"}
             } = job

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
                      data: job
                    }, []}
               ]
             } = TestJobScheduler.schedule(Multi.new(), TestJob, params)

      assert %EctoJobScheduler.Test.TestJobQueue{
               params: %{"context" => result_context, "data" => "any"}
             } = job

      assert expected_context == result_context
    end

    test "should schedule with a struct as param" do
      assert %Multi{
               operations: [
                 test_job:
                   {:changeset,
                    %Changeset{
                      action: :insert,
                      valid?: true,
                      data: %{
                        params: %{"some" => "some", "field" => "field"}
                      }
                    }, []}
               ]
             } =
               TestJobScheduler.schedule(Multi.new(), TestJob, %TestJobParams{
                 some: "some",
                 field: "field"
               })
    end

    test "should pass additional options to enqueue function" do
      schedule = NaiveDateTime.utc_now()

      assert %Multi{
               operations: [
                 test_job:
                   {:changeset,
                    %Changeset{
                      action: :insert,
                      valid?: true,
                      data: job
                    }, []}
               ]
             } =
               TestJobScheduler.schedule(
                 Multi.new(),
                 TestJob,
                 %TestJobParams{
                   some: "some",
                   field: "field"
                 },
                 schedule: schedule
               )

      assert %EctoJobScheduler.Test.TestJobQueue{
               params: %{
                 "field" => "field",
                 "some" => "some",
                 "type" => "TestJob"
               },
               schedule: ^schedule
             } = job
    end

    test "should override config from job module" do
      max_attempts = 4

      assert %Multi{
               operations: [
                 test_job:
                   {:changeset,
                    %Changeset{
                      action: :insert,
                      valid?: true,
                      data: job
                    }, []}
               ]
             } =
               TestJobScheduler.schedule(
                 Multi.new(),
                 TestJob,
                 %TestJobParams{
                   some: "some",
                   field: "field"
                 },
                 max_attempts: max_attempts
               )

      assert %EctoJobScheduler.Test.TestJobQueue{
               params: %{
                 "field" => "field",
                 "some" => "some",
                 "type" => "TestJob"
               },
               max_attempts: ^max_attempts
             } = job
    end
  end
end
