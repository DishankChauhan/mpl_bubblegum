# MPL-Bubblegum Production Deployment Guide


## Prerequisites
- Elixir 1.14+
- Rust 1.70+
- Solana CLI tools
- Production Solana RPC endpoint

## Step 1: Environment Setup

1. Configure environment variables:
```bash
export SOLANA_CLUSTER=mainnet-beta
export SOLANA_RPC_URL=your_rpc_endpoint
export MPL_BUBBLEGUM_PRIVATE_KEY=your_private_key