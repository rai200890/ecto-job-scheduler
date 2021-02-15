defmodule EctoJobScheduler.JobQueueTest do
  @moduledoc false
  use EctoJobScheduler.DataCase, async: true

  import Mox

  alias EctoJobScheduler.Logger.Context
  alias EctoJobScheduler.Test.EctoJobHelpers
  alias EctoJobScheduler.Test.Repo
  alias EctoJobScheduler.Test.TestJobQueue
  alias EctoJobScheduler.Test.TestJobQueueNewRelic

  @moduletag :capture_log

  setup :verify_on_exit!

  describe "perform/3" do
    Enum.each([TestJobQueue, TestJobQueueNewRelic], fn job_queue ->
      test "#{job_queue} when job returns multi and return is successful, should delete job" do
        :ok =
          :telemetry.attach(
            "#{unquote(job_queue)}-job-execution-stop-handler",
            [:ecto_job_scheduler, :job_execution, :stop],
            fn event, measurements, metadata, config ->
              send(self(), {event, measurements, metadata, config})
            end,
            nil
          )

        job_args = %{
          "type" => "TestJob",
          "little master" => "Rai99",
          "cpf" => "12345678910",
          "xablau" => "jo",
          "context" => %{some: :thing}
        }

        EctoJobHelpers.build_initial_multi(Repo, unquote(job_queue), job_args)

        job_queue = unquote(job_queue)
        job = Repo.one(job_queue)

        mock_report(job_queue)

        assert {:ok, %{test_job: :xablau}} =
                 EctoJobHelpers.dispatch_job(Repo, unquote(job_queue), job)

        assert Repo.all(unquote(job_queue)) == []

        assert [
                 params: %{"type" => "TestJob"},
                 max_attempts: 5,
                 attempt: 1,
                 some: "thing"
               ] = Context.get()

        assert_received {[:ecto_job_scheduler, :job_execution, :stop], _measurements, _metadata,
                         _config}
      end

      test "#{job_queue} when job returns multi and return fails, should update job attempt" do
        job_args = %{
          "type" => "TestJobError",
          "context" => %{some: :thing}
        }

        EctoJobHelpers.build_initial_multi(Repo, unquote(job_queue), job_args)

        job_queue = unquote(job_queue)
        job = Repo.one(unquote(job_queue))

        mock_report(job_queue)

        assert {:error, :test_job, :xablau, %{}} =
                 EctoJobHelpers.dispatch_job(Repo, unquote(job_queue), job)

        assert [
                 %unquote(job_queue){
                   attempt: 1,
                   params: %{"context" => %{"some" => "thing"}, "type" => "TestJobError"}
                 }
               ] = Repo.all(unquote(job_queue))

        assert [
                 params: %{"type" => "TestJobError"},
                 max_attempts: 5,
                 attempt: 1,
                 some: "thing"
               ] = Context.get()
      end

      test "#{job_queue} when job doesn't return multi and return is successful, should delete job" do
        job_args = %{
          "type" => "TestJobNotMultiSuccessful",
          "context" => %{some: :thing}
        }

        EctoJobHelpers.build_initial_multi(Repo, unquote(job_queue), job_args)

        job_queue = unquote(job_queue)
        job = Repo.one(unquote(job_queue))

        mock_report(job_queue)

        assert {:ok, :xablau} == EctoJobHelpers.dispatch_job(Repo, unquote(job_queue), job)

        assert Repo.all(unquote(job_queue)) == []

        assert [
                 params: %{"type" => "TestJobNotMultiSuccessful"},
                 max_attempts: 5,
                 attempt: 1,
                 some: "thing"
               ] = Context.get()
      end

      test "#{job_queue} when job doesn't return multi and fails, should update job attempt" do
        if unquote(job_queue) == TestJobQueueNewRelic do
        end

        job_args = %{
          "type" => "TestJobNotMultiError",
          "context" => %{some: :thing}
        }

        EctoJobHelpers.build_initial_multi(Repo, unquote(job_queue), job_args)

        job_queue = unquote(job_queue)
        job = Repo.one(unquote(job_queue))

        mock_report_fail(job_queue)

        assert {:error, :sad_keanu} ==
                 EctoJobHelpers.dispatch_job(Repo, unquote(job_queue), job)

        assert [
                 %unquote(job_queue){
                   attempt: 1,
                   params: %{
                     "context" => %{"some" => "thing"},
                     "type" => "TestJobNotMultiError"
                   }
                 }
               ] = Repo.all(unquote(job_queue))

        assert [
                 params: %{"type" => "TestJobNotMultiError"},
                 max_attempts: 5,
                 attempt: 1,
                 some: "thing"
               ] = Context.get()
      end

      test "#{job_queue} when job raises exception, should update job attempt" do
        :ok =
          :telemetry.attach(
            "#{unquote(job_queue)}-job-execution-exception-handler",
            [:ecto_job_scheduler, :job_execution, :exception],
            fn event, measurements, metadata, config ->
              send(self(), {event, measurements, metadata, config})
            end,
            nil
          )

        job_args = %{
          "type" => "TestJobException",
          "context" => %{some: :thing}
        }

        EctoJobHelpers.build_initial_multi(Repo, unquote(job_queue), job_args)

        job_queue = unquote(job_queue)
        job = Repo.one(unquote(job_queue))

        mock_report_fail(job_queue)

        assert_raise RuntimeError, "Xablau!", fn ->
          EctoJobHelpers.dispatch_job(Repo, unquote(job_queue), job)
        end

        assert [
                 %unquote(job_queue){
                   attempt: 1,
                   params: %{"context" => %{"some" => "thing"}, "type" => "TestJobException"}
                 }
               ] = Repo.all(unquote(job_queue))

        assert [
                 params: %{"type" => "TestJobException"},
                 max_attempts: 5,
                 attempt: 1,
                 some: "thing"
               ] = Context.get()

        assert_received {[:ecto_job_scheduler, :job_execution, :exception], _measurements, _metadata,
               _config}
      end
    end)
  end

  defp mock_report(TestJobQueueNewRelic) do
    TransactionMock
    |> expect(:stop_transaction, fn -> :ok end)

    ReporterMock
    |> expect(:start, fn -> :ok end)
    |> expect(:add_attributes, fn _ -> :ok end)
  end

  defp mock_report(_job_queue), do: nil

  defp mock_report_fail(TestJobQueueNewRelic) do
    TestJobQueueNewRelic |> mock_report() |> expect(:fail, fn _, _ -> :ok end)
  end

  defp mock_report_fail(_job_queue), do: nil
end
