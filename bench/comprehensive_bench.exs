defmodule MplBubblegum.ComprehensiveBench do
  @moduledoc """
  Comprehensive benchmarks for MPL-Bubblegum operations.
  
  """

  alias MplBubblegum.Devnet

  def run_all_benchmarks do
    {:ok, test_wallet} = Devnet.create_test_wallet()
    
    Benchee.run(
      %{
        "tree_creation" => fn -> 
          benchmark_tree_creation(test_wallet) 
        end,
        "nft_minting" => fn -> 
          benchmark_nft_minting(test_wallet) 
        end,
        "nft_transfer" => fn -> 
          benchmark_nft_transfer(test_wallet) 
        end
      },
      time: 30,
      memory_time: 2,
      parallel: 4,
      formatters: [
        {Benchee.Formatters.HTML, file: "bench/output/results.html"},
        {Benchee.Formatters.Console, extended_statistics: true}
      ],
      pre_check: true
    )
  end

  defp benchmark_tree_creation(wallet) do
    MplBubblegum.create_tree_config(14, 64, wallet.public_key)
  end

  defp benchmark_nft_minting(wallet) do
    {:ok, tree_address} = MplBubblegum.create_tree_config(14, 64, wallet.public_key)
    
    MplBubblegum.mint_compressed_nft(
      tree_address,
      "https://example.com/metadata.json",
      "Bench NFT",
      "BNFT"
    )
  end

  defp benchmark_nft_transfer(wallet) do
    {:ok, recipient} = Devnet.create_test_wallet()
    
    MplBubblegum.transfer_compressed_nft(
      "test_nft_address",
      wallet.public_key,
      recipient.public_key
    )
  end
end