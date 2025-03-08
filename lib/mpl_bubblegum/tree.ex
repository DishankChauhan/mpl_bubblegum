defmodule MplBubblegum.Tree do
  @moduledoc """
  Handles compressed NFT tree operations.
  """

  alias MplBubblegum.Error

  @type tree_config :: %{
    max_depth: integer(),
    max_buffer_size: integer(),
    public_key: String.t()
  }

  @doc """
  Creates a new tree config for compressed NFTs.
  """
  @spec create_config(tree_config()) :: {:ok, String.t()} | {:error, Error.t()}
  def create_config(%{max_depth: max_depth, max_buffer_size: max_buffer_size, public_key: public_key}) do
    case MplBubblegum.create_tree_config(max_depth, max_buffer_size, public_key) do
      {:ok, tree_address} -> {:ok, tree_address}
      {:error, reason} -> {:error, Error.new(:create_tree_failed, reason)}
    end
  end
end