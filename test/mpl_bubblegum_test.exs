defmodule MplBubblegumTest do
  use ExUnit.Case
  doctest MplBubblegum

  @test_keypair "5MaiiCavjCmn9Hs1o3eznqDEhRwxo7pXiAYez7keQUviUkauRiTMD8DrESdrNjN8zd9mTmVhRvBJeg5vhyvgrAhG"

  describe "tree operations" do
    test "creates tree config with valid parameters" do
      assert {:ok, tree_address} = MplBubblegum.create_tree_config(14, 64, @test_keypair)
      assert is_binary(tree_address)
      assert String.length(tree_address) > 0
    end

    test "fails to create tree config with invalid public key" do
      assert {:error, message} = MplBubblegum.create_tree_config(14, 64, "invalid_key")
      assert message =~ "Invalid public key"
    end
  end

  describe "NFT operations" do
    setup do
      {:ok, tree_address} = MplBubblegum.create_tree_config(14, 64, @test_keypair)
      {:ok, tree_address: tree_address}
    end

    test "mints compressed NFT", %{tree_address: tree_address} do
      assert {:ok, nft_address} = MplBubblegum.mint_compressed_nft(
        tree_address,
        "https://example.com/metadata.json",
        "Test NFT",
        "TNFT"
      )
      assert is_binary(nft_address)
    end

    test "transfers compressed NFT" do
      sender = @test_keypair
      recipient = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
      nft_address = "7closed7closed7closed7closed7closed7closed7c"

      assert {:ok, result} = MplBubblegum.transfer_compressed_nft(
        nft_address,
        sender,
        recipient
      )
      assert is_binary(result)
    end
  end
end