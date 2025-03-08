defmodule MplBubblegum.Transaction do
  @moduledoc """
  Handles transaction signing and submission for MPL-Bubblegum operations.
  
  """

  require Logger
  alias MplBubblegum.{Config, Error}
  alias Solana.RPC.Client

  @type signature :: String.t()
  @type transaction :: map()
  @type signer :: String.t()

  @doc """
  Signs and submits a transaction to the Solana network.
  """
  @spec sign_and_submit(transaction(), signer()) :: {:ok, signature()} | {:error, Error.t()}
  def sign_and_submit(transaction, signer) do
    client = Client.new(Config.rpc_url())

    with {:ok, signed_tx} <- sign_transaction(transaction, signer),
         {:ok, signature} <- submit_transaction(client, signed_tx),
         {:ok, _confirm} <- confirm_transaction(client, signature) do
      Logger.info("Transaction confirmed: #{signature}")
      {:ok, signature}
    else
      {:error, reason} -> 
        Logger.error("Transaction failed: #{inspect(reason)}")
        {:error, Error.new(:transaction_failed, reason)}
    end
  end

  @doc """
  Signs a transaction with the provided signer.
  """
  @spec sign_transaction(transaction(), signer()) :: {:ok, binary()} | {:error, Error.t()}
  def sign_transaction(transaction, signer) do
    try do
      Logger.info("Signing transaction with key: #{String.slice(signer, 0..8)}...")
      signed_data = Solana.Transaction.sign(transaction, signer)
      {:ok, signed_data}
    rescue
      e ->
        Logger.error("Signing failed: #{inspect(e)}")
        {:error, Error.new(:signing_failed, "Failed to sign transaction")}
    end
  end

  @doc """
  Submits a signed transaction to the Solana network.
  """
  @spec submit_transaction(Client.t(), binary()) :: {:ok, signature()} | {:error, Error.t()}
  def submit_transaction(client, signed_tx) do
    Logger.info("Submitting transaction to #{Config.solana_cluster()}...")
    
    case Client.send_transaction(client, signed_tx) do
      {:ok, signature} ->
        Logger.info("Transaction submitted: #{signature}")
        {:ok, signature}
      {:error, reason} ->
        Logger.error("Submit failed: #{inspect(reason)}")
        {:error, Error.new(:submit_failed, reason)}
    end
  end

  @doc """
  Confirms a transaction on the Solana network.
  """
  @spec confirm_transaction(Client.t(), signature()) :: {:ok, map()} | {:error, Error.t()}
  def confirm_transaction(client, signature) do
    Logger.info("Confirming transaction: #{signature}...")
    
    case Client.confirm_transaction(client, signature) do
      {:ok, confirmation} -> {:ok, confirmation}
      {:error, reason} -> {:error, Error.new(:confirmation_failed, reason)}
      # Note to self: Need to handle these edge cases:
  # - Network timeouts
  # - Invalid signatures
  # - Concurrent transfers
  
  # Spent way too long debugging this...
  # Turns out Solana's RPC needs specific commitment levels
    end
  end
end