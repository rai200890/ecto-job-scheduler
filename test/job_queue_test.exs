defmodule EctoJobScheduler.JobQueueTest do
  @moduledoc false
  use EctoJobScheduler.DataBase

  alias EctoJobScheduler.Logger.Context
  alias EctoJobScheduler.Test.EctoJobHelpers
  alias EctoJobScheduler.Test.Repo
  alias EctoJobScheduler.Test.TestJobQueue

  @moduletag :capture_log

  describe "perform/3" do
    test "when job returns multi and return is successful, should delete job" do
      job_args = %{
        "type" => "TestJob",
        "little master" => "Rai99",
        "cpf" => "12345678910",
        "xablau" => "jo",
        "context" => %{some: :thing}
      }

      EctoJobHelpers.build_initial_multi(Repo, TestJobQueue, job_args)

      job = Repo.one(TestJobQueue)

      assert {:ok, %{test_job: :xablau}} = EctoJobHelpers.dispatch_job(Repo, TestJobQueue, job)

      assert Repo.all(TestJobQueue) == []

      assert [
               params: %{"type" => "TestJob"},
               max_attempts: 5,
               attempt: 1,
               some: "thing"
             ] = Context.get()
    end

    test "when job returns multi and return fails, should update job attempt" do
      job_args = %{
        "type" => "TestJobError",
        "context" => %{some: :thing}
      }

      EctoJobHelpers.build_initial_multi(Repo, TestJobQueue, job_args)

      job = Repo.one(TestJobQueue)

      assert {:error, :test_job, :xablau, %{}} =
               EctoJobHelpers.dispatch_job(Repo, TestJobQueue, job)

      assert [
               %TestJobQueue{
                 attempt: 1,
                 params: %{"context" => %{"some" => "thing"}, "type" => "TestJobError"}
               }
             ] = Repo.all(TestJobQueue)

      assert [
               params: %{"type" => "TestJobError"},
               max_attempts: 5,
               attempt: 1,
               some: "thing"
             ] = Context.get()
    end

    test "when job doesn't return multi and return is successful, should delete job" do
      job_args = %{
        "type" => "TestJobNotMultiSuccessful",
        "context" => %{some: :thing}
      }

      EctoJobHelpers.build_initial_multi(Repo, TestJobQueue, job_args)

      job = Repo.one(TestJobQueue)

      assert {:ok, :xablau} == EctoJobHelpers.dispatch_job(Repo, TestJobQueue, job)

      assert Repo.all(TestJobQueue) == []

      assert [
               params: %{"type" => "TestJobNotMultiSuccessful"},
               max_attempts: 5,
               attempt: 1,
               some: "thing"
             ] = Context.get()
    end

    test "when job doesn't return multi and fails, should update job attempt" do
      job_args = %{
        "type" => "TestJobNotMultiError",
        "context" => %{some: :thing}
      }

      EctoJobHelpers.build_initial_multi(Repo, TestJobQueue, job_args)

      job = Repo.one(TestJobQueue)

      assert {:error, :sad_keanu} == EctoJobHelpers.dispatch_job(Repo, TestJobQueue, job)

      assert [
               %TestJobQueue{
                 attempt: 1,
                 params: %{"context" => %{"some" => "thing"}, "type" => "TestJobNotMultiError"}
               }
             ] = Repo.all(TestJobQueue)

      assert [
               params: %{"type" => "TestJobNotMultiError"},
               max_attempts: 5,
               attempt: 1,
               some: "thing"
             ] = Context.get()
    end
  end
end
