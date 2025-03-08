defmodule MplBubblegum.NFT do
  @moduledoc """
  Handles compressed NFT operations.
  """

  alias MplBubblegum.Error

  @type metadata :: %{
    name: String.t(),
    symbol: String.t(),
    uri: String.t()
  }

  @doc """
  Mints a new compressed NFT.
  """
  @spec mint(metadata(), String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def mint(%{name: name, symbol: symbol, uri: uri}, tree_address) do
    case MplBubblegum.mint_compressed_nft(tree_address, uri, name, symbol) do
      {:ok, nft_address} -> {:ok, nft_address}
      {:error, reason} -> {:error, Error.new(:mint_failed, reason)}
    end
  end

  @doc """
  Transfers a compressed NFT to a new owner.
  """
  @spec transfer(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def transfer(nft_address, from, to) do
    case MplBubblegum.transfer_compressed_nft(nft_address, from, to) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, Error.new(:transfer_failed, reason)}
    end
  end
end