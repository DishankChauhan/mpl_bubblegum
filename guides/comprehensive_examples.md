# MPL-Bubblegum Comprehensive Examples


## Complete NFT Collection Creation

```elixir
defmodule NFTCollectionExample do
  alias MplBubblegum.{Devnet, Transaction}

  def create_collection do
    # Create test wallet
    {:ok, wallet} = Devnet.create_test_wallet()

    # Create tree configuration
    {:ok, tree_address} = MplBubblegum.create_tree_config(
      14,  # Max depth
      64,  # Buffer size
      wallet.public_key
    )

    # Mint multiple NFTs
    nfts = Enum.map(1..5, fn i ->
      {:ok, nft_address} = MplBubblegum.mint_compressed_nft(
        tree_address,
        "https://api.example.com/metadata/#{i}.json",
        "NFT ##{i}",
        "CNFT"
      )
      nft_address
    end)

    # Transfer an NFT
    {:ok, recipient} = Devnet.create_test_wallet()
    [first_nft | _] = nfts

    {:ok, signature} = MplBubblegum.transfer_compressed_nft(
      first_nft,
      wallet.public_key,
      recipient.public_key
    )

    {:ok, %{
      tree: tree_address,
      nfts: nfts,
      transfer: signature
    }}
  end
end
```

## Batch Operations

```elixir
defmodule BatchOperationsExample do
  def batch_mint(tree_address, count) do
    Task.async_stream(
      1..count,
      fn i ->
        MplBubblegum.mint_compressed_nft(
          tree_address,
          "https://api.example.com/metadata/#{i}.json",
          "Batch NFT ##{i}",
          "BNFT"
        )
      end,
      max_concurrency: 5,
      timeout: 30_000
    )
    |> Enum.to_list()
  end
end
```

## Error Handling

```elixir
defmodule ErrorHandlingExample do
  def safe_transfer(nft_address, from, to) do
    case MplBubblegum.transfer_compressed_nft(nft_address, from, to) do
      {:ok, signature} ->
        Logger.info("Transfer successful: #{signature}")
        {:ok, signature}
      
      {:error, %Error{type: :invalid_public_key}} ->
        Logger.error("Invalid public key provided")
        {:error, :invalid_keys}
      
      {:error, %Error{type: :transaction_failed, message: msg}} ->
        Logger.error("Transaction failed: #{msg}")
        {:error, :transaction_failed}
      
      {:error, _} ->
        Logger.error("Unknown error occurred")
        {:error, :unknown_error}
    end
  end
end
```