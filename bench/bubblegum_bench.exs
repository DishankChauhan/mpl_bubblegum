defmodule MplBubblegum.Benchmark do
  @moduledoc """
  
  """

  def run_benchmarks do
    Benchee.run(
      %{
        "create_tree_config" => fn ->
          MplBubblegum.create_tree_config(14, 64, test_keypair())
        end,
        "mint_compressed_nft" => fn ->
          MplBubblegum.mint_compressed_nft(
            test_tree_address(),
            "https://example.com/metadata.json",
            "Test NFT",
            "TNFT"
          )
        end,
        "transfer_compressed_nft" => fn ->
          MplBubblegum.transfer_compressed_nft(
            test_nft_address(),
            test_keypair(),
            test_recipient()
          )
        end
      },
      time: 10,
      memory_time: 2
    )
  end

  defp test_keypair, do: "test_keypair"
  defp test_tree_address, do: "test_tree_address"
  defp test_nft_address, do: "test_nft_address"
  defp test_recipient, do: "test_recipient"
end