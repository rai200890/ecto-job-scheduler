defmodule EctoJobScheduler.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_job_scheduler,
      version: "./VERSION" |> File.read!() |> String.trim(),
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      description: description(),
      package: package(),
      source_url: "https://github.com/rai200890/ecto-job-scheduler",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "test", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test", "test/support"]

  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "Helpers for scheduling Jobs defined in EctoJob"
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* VERSION*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rai200890/ecto-job-scheduler"}
    ]
  end

  defp deps do
    [
      {:ecto_job, "~> 3.0"},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
