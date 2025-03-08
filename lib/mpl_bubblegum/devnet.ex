defmodule MplBubblegum.Devnet do
  @moduledoc """
  Provides devnet-specific functionality for testing and development.
  Created by: DishankChauhan
  Last Updated: 2025-03-08 16:57:10 UTC
  """

  require Logger
  alias MplBubblegum.{Config, Error, Transaction}
  alias Solana.RPC.Client

  @doc """
  Requests airdrop of SOL for testing on devnet.
  """
  @spec request_airdrop(String.t(), number()) :: {:ok, String.t()} | {:error, Error.t()}
  def request_airdrop(public_key, amount \\ 1.0) do
    client = Client.new(Config.rpc_url())
    
    case Client.request_airdrop(client, public_key, amount) do
      {:ok, signature} ->
        Logger.info("Airdrop requested: #{signature}")
        Transaction.confirm_transaction(client, signature)
      {:error, reason} ->
        Logger.error("Airdrop failed: #{inspect(reason)}")
        {:error, Error.new(:airdrop_failed, reason)}
    end
  end

  @doc """
  Creates a test wallet for devnet usage.
  """
  @spec create_test_wallet() :: {:ok, map()} | {:error, Error.t()}
  def create_test_wallet do
    try do
      keypair = Solana.Keypair.generate()
      
      case request_airdrop(keypair.public_key) do
        {:ok, _} -> {:ok, keypair}
        error -> error
      end
    rescue
      e ->
        Logger.error("Wallet creation failed: #{inspect(e)}")
        {:error, Error.new(:wallet_creation_failed, "Failed to create test wallet")}
    end
  end
end