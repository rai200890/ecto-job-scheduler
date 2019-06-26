defmodule EctoJobScheduler.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_job_scheduler,
      version: "./VERSION" |> File.read!() |> String.trim(),
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "test", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test", "test/support"]

  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto_job, "~> 2.1"}
    ]
  end
end
