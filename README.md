# EctoJobScheduler

[![CircleCI](https://circleci.com/gh/rai200890/ecto-job-scheduler/tree/master.svg?style=svg)](https://circleci.com/gh/rai200890/ecto-job-scheduler/tree/master)
![Hex.pm](https://img.shields.io/hexpm/v/ecto_job_scheduler.svg)
![Hex.pm](https://img.shields.io/hexpm/l/ecto_job_scheduler.svg)

Helpers for scheduling Jobs defined in [EctoJob](https://github.com/mbuhot/ecto_job)

Thanks [joaothallis](https://github.com/joaothallis), [ramondelemos](https://github.com/ramondelemos), [victorprs](https://github.com/victorprs)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_job_scheduler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_job_scheduler, "~> 1.0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_job_scheduler](https://hexdocs.pm/ecto_job_scheduler).

## Usage

### Define job

```elixir
defmodule MyApplication.MyJob do
  @moduledoc false
  use EctoJobScheduler.Job,
    repo: MyApplication.Repo,
    otp_app: :my_application

  def handle_job(%JobInfo{multi: _multi}, %{"input" => input}) do
    case input do
      :a -> :ok
      :b -> {:ok, :gotta_go_fast}
      other -> {:error, :xablau}
    end
  end
end
```

### Define job queue

```elixir
defmodule MyApplication.MyJobQueue do
  @moduledoc false
  use EctoJobScheduler.JobQueue,
    table_name: "test_jobs",
    jobs: [
      MyApplication.MyJob
    ]
end
```

If you want new_relic instrumentation in your jobs, add new_relic_agent to the deps and

```elixir
defmodule MyApplication.MyJobQueue do
  @moduledoc false
  use EctoJobScheduler.JobQueue,
    table_name: "test_jobs",
    jobs: [
      MyApplication.MyJob
    ],
    instrumenter: :new_relic
end
```

### Define scheduler module for job queue

```elixir
defmodule MyApplication.MyJobScheduler do
  @moduledoc false
  use EctoJobScheduler.JobScheduler,
  repo: MyApplication.Repo,
  job_queue: MyApplication.MyJobQueue
end
```

### Configuration

```elixir
config :my_application, MyApplication.MyJob, max_attempts: "15"
```

## Running and scheduling jobs

### Enqueuing right away

```elixir
{:ok, job_queue} = MyJobScheduler.run(MyJob, %{"input" => "a"})
{:ok, job_queue} = MyJobScheduler.run(MyJob, %{"input" => "a"}, schedule:  ~N[2022-10-03 12:00:00.000000]) # pass additional options

```

### Appending to Ecto.Multi

```elixir
  multi = Multi.run(:do_my_thing, fn _repo, _changes -> {:ok, :xablau} end)
  multi = MyJobScheduler.schedule(multi, MyJob, %{"input" => "a"})
  result = MyJobScheduler.run(multi)
```
