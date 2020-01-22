defmodule EctoJobScheduler.Test.Repo.Migrations.UpdateJobQueue do
  use Ecto.Migration

  @ecto_job_version 3
  @table_name "test_jobs"

  def up do
    EctoJob.Migrations.UpdateJobTable.up(@ecto_job_version, @table_name)
  end

  def down do
    EctoJob.Migrations.UpdateJobTable.down(@ecto_job_version, @table_name)
  end
end
