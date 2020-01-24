defmodule EctoJobScheduler.Test.Repo.Migrations.UpdateJobQueue do
  use Ecto.Migration

  alias EctoJob.Migrations.UpdateJobTable

  @ecto_job_version 3
  @table_name "test_jobs"

  def up do
    UpdateJobTable.up(@ecto_job_version, @table_name)
  end

  def down do
    UpdateJobTable.down(@ecto_job_version, @table_name)
  end
end
