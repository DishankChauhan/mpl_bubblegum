config :mpl_bubblegum,
  solana_cluster: System.get_env("SOLANA_CLUSTER"),
  rpc_url: System.get_env("SOLANA_RPC_URL"),
  private_key: System.get_env("MPL_BUBBLEGUM_PRIVATE_KEY")