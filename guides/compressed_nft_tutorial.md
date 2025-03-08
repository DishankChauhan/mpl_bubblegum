# MPL-Bubblegum Compressed NFT Tutorial

## Introduction
This guide will walk you through creating and managing compressed NFTs using the MPL-Bubblegum Elixir library.

## Installation
Add to your `mix.exs`:
```elixir
def deps do
  [
    {:mpl_bubblegum, "~> 0.1.0"}
  ]
end
```

## Basic Usage

### Creating a Tree Configuration
```elixir
# Initialize a new merkle tree configuration
{:ok, tree_address} = MplBubblegum.create_tree_config(
  max_depth: 14,
  max_buffer_size: 64,
  public_key: "your_public_key"
)
```

### Minting a Compressed NFT
```elixir
# Mint a new compressed NFT
{:ok, nft_address} = MplBubblegum.mint_compressed_nft(
  tree_address,
  "https://example.com/metadata.json",
  "My NFT",
  "MNFT"
)
```

### Transferring a Compressed NFT
```elixir
# Transfer an NFT to a new owner
{:ok, signature} = MplBubblegum.transfer_compressed_nft(
  nft_address,
  sender_address,
  recipient_address
)
```