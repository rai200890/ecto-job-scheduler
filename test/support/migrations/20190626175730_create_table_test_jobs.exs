defmodule EctoJobScheduler.Test.Repo.Migrations.CreateTableTestJobs do
  use Ecto.Migration
  alias EctoJob.Migrations

  @table_name "test_jobs"

  def up do
    Migrations.Install.up()
    Migrations.CreateJobTable.up(@table_name)
  end

  def down do
    Migrations.CreateJobTable.down(@table_name)
    Migrations.Install.down()
  end
end
