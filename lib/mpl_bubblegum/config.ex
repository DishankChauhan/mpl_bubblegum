defmodule MplBubblegum.Config do
  @moduledoc """
  Configuration module for MPL-Bubblegum.
  """

  def solana_cluster do
    Application.get_env(:mpl_bubblegum, :solana_cluster, "devnet")
  end

  def rpc_url do
    case solana_cluster() do
      "mainnet-beta" -> "https://api.mainnet-beta.solana.com"
      "devnet" -> "https://api.devnet.solana.com"
      "testnet" -> "https://api.testnet.solana.com"
      custom when is_binary(custom) -> custom
    end
  end
end