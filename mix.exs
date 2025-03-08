defmodule MplBubblegum.MixProject do
  use Mix.Project

  def project do
    [
      app: :mpl_bubblegum,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Remove the compiler entry since it's deprecated
      rustler_crates: rustler_crates()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.29.1", runtime: false},  # Add runtime: false
      {:solana, "~> 0.2.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:benchee, "~> 1.1", only: :dev}
    ]
  end

  defp rustler_crates do
    [
      mpl_bubblegum: [
        path: "native/mpl_bubblegum",
        mode: :debug,
        default_features: true,
        features: [],
        crate: :mpl_bubblegum,
        load_from: {:mpl_bubblegum, "priv/native/libmpl_bubblegum"}
      ]
    ]
  end
end