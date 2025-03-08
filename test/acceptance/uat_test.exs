defmodule MplBubblegum.AcceptanceTest do
  use ExUnit.Case
  doctest MplBubblegum

  @moduledoc """
  User Acceptance Tests for MPL-Bubblegum
  Created by: DishankChauhan
  Last Updated: 2025-03-08 17:07:08 UTC
  """

  setup do
    {:ok, wallet} = MplBubblegum.Devnet.create_test_wallet()
    {:ok, wallet: wallet}
  end

  describe "End-to-End NFT Creation Flow" do
    test "complete NFT lifecycle", %{wallet: wallet} do
      # 1. Create Tree Configuration
      {:ok, tree_address} = MplBubblegum.create_tree_config(
        14,
        64,
        wallet.public_key
      )
      assert is_binary(tree_address)

      # 2. Mint NFT
      {:ok, nft_address} = MplBubblegum.mint_compressed_nft(
        tree_address,
        "https://example.com/metadata.json",
        "Test NFT",
        "TNFT"
      )
      assert is_binary(nft_address)

      # 3. Transfer NFT
      {:ok, recipient} = MplBubblegum.Devnet.create_test_wallet()
      {:ok, signature} = MplBubblegum.transfer_compressed_nft(
        nft_address,
        wallet.public_key,
        recipient.public_key
      )
      assert is_binary(signature)
    end

    test "batch operations", %{wallet: wallet} do
      {:ok, tree_address} = MplBubblegum.create_tree_config(14, 64, wallet.public_key)
      
      # Batch mint 5 NFTs
      results = MplBubblegum.Performance.batch_process(
        Enum.map(1..5, fn i ->
          {:mint, %{
            tree_address: tree_address,
            metadata_uri: "https://example.com/metadata/#{i}.json",
            name: "NFT ##{i}",
            symbol: "BNFT"
          }}
        end)
      )

      assert length(results) == 5
      assert Enum.all?(results, fn {:ok, _} -> true end)
    end
  end

  describe "Error Handling" do
    test "handles invalid public key gracefully" do
      result = MplBubblegum.create_tree_config(14, 64, "invalid_key")
      assert {:error, _} = result
    end

    test "handles invalid tree address" do
      result = MplBubblegum.mint_compressed_nft(
        "invalid_tree",
        "https://example.com/metadata.json",
        "Test NFT",
        "TNFT"
      )
      assert {:error, _} = result
    end
  end
end