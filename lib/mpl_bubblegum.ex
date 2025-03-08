defmodule MplBubblegum do
  @moduledoc """
  MPL-Bubblegum integration for Elixir.
  Implements compressed NFT operations on Solana using the MPL-Bubblegum protocol.

  Created by: DishankChauhan
  Last Updated: 2025-03-08
  """

  use Rustler, otp_app: :mpl_bubblegum, crate: "mpl_bubblegum"

  @doc """
  Creates a new tree configuration for compressed NFTs.

  ## Parameters
    * max_depth: Maximum depth of the merkle tree
    * max_buffer_size: Maximum buffer size for the tree
    * public_key: The public key of the tree creator

  ## Returns
    * `{:ok, tree_address}` - Successfully created tree config
    * `{:error, reason}` - Failed to create tree config

  ## Example
      iex> MplBubblegum.create_tree_config(14, 64, "your_public_key")
      {:ok, "tree_address"}
  """
  @spec create_tree_config(integer(), integer(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def create_tree_config(_max_depth, _max_buffer_size, _public_key), 
    do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Mints a new compressed NFT.

  ## Parameters
    * tree_address: The address of the merkle tree
    * metadata_uri: URI pointing to the NFT metadata
    * name: Name of the NFT
    * symbol: Symbol of the NFT

  ## Returns
    * `{:ok, nft_address}` - Successfully minted NFT
    * `{:error, reason}` - Failed to mint NFT

  ## Example
      iex> MplBubblegum.mint_compressed_nft("tree_address", "https://example.com/metadata.json", "MyNFT", "MNFT")
      {:ok, "nft_address"}
  """
  @spec mint_compressed_nft(String.t(), String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def mint_compressed_nft(_tree_address, _metadata_uri, _name, _symbol),
    do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Transfers a compressed NFT to a new owner.

  ## Parameters
    * nft_address: The address of the NFT to transfer
    * from: The current owner's address
    * to: The new owner's address

  ## Returns
    * `{:ok, transaction_signature}` - Successfully transferred NFT
    * `{:error, reason}` - Failed to transfer NFT

  ## Example
      iex> MplBubblegum.transfer_compressed_nft("nft_address", "sender_address", "recipient_address")
      {:ok, "transaction_signature"}
  """
  @spec transfer_compressed_nft(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def transfer_compressed_nft(_nft_address, _from, _to),
    do: :erlang.nif_error(:nif_not_loaded)
end