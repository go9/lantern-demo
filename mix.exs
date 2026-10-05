defmodule LanternDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :lantern_demo,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {LanternDemo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:lantern, github: "go9/lantern"},
      # lantern_ui from git at a pinned main sha (Zag widgets, page blocks, shadcn
      # preset, toast deck, row links). Repin when lantern-ui releases.
      {:lantern_ui,
       github: "go9/lantern-ui", ref: "ed14a0092ddfa7633e5056a08a2231b9409518b0", override: true},
      {:lantern_s3, github: "go9/lantern-s3"},
      {:phoenix, "~> 1.8"},
      {:phoenix_live_view, "~> 1.1"},
      {:postgrex, "~> 0.17"},
      {:jason, "~> 1.0"},
      {:bandit, "~> 1.7"},
      {:req, "~> 0.5"},
      {:lazy_html, ">= 0.1.0", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "lantern_demo.seed"]
    ]
  end
end
