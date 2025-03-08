# MPL-Bubblegum Elixir Integration


## Overview
A Rust NIF implementation for Solana's MPL-Bubblegum compressed NFT protocol in Elixir. This library provides functionality for creating, minting, and managing compressed NFTs on Solana.

## Features
- Create compressed NFT tree configurations
- Mint compressed NFTs (single and batch)
- Transfer compressed NFTs
- Verify collection items
- Burn compressed NFTs
- Transaction monitoring and retry logic
- Performance optimizations

## Installation

Add to your `mix.exs`:
```elixir
def deps do
  [
    {:mpl_bubblegum, git: "https://github.com/dishankchauhan/mpl_bubblegum.git", tag: "v0.1.0"}
  ]
end
```

## Prerequisites
- Elixir 1.14+
- Rust 1.70+
- Solana CLI tools

## Quick Start

```elixir
# Create a tree configuration
{:ok, tree_address} = MplBubblegum.create_tree_config(14, 64, public_key)

# Mint a compressed NFT
{:ok, nft_address} = MplBubblegum.mint_compressed_nft(
  tree_address,
  "https://example.com/metadata.json",
  "My NFT",
  "MNFT"
)

# Transfer a compressed NFT
{:ok, signature} = MplBubblegum.transfer_compressed_nft(
  nft_address,
  sender_address,
  recipient_address
)
```

## Documentation
Full documentation can be found at [HexDocs](https://hexdocs.pm/mpl_bubblegum).

## Development

```bash
# Clone the repository
git clone https://github.com/dishankchauhan/mpl_bubblegum.git
cd mpl_bubblegum

# Install dependencies
mix deps.get

# Compile
mix compile

# Run tests
mix test
```

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.