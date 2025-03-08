defmodule MplBubblegum.Error do
  @moduledoc """
  Error handling for MPL-Bubblegum operations.
  """

  defstruct [:type, :message]

  @type t :: %__MODULE__{
    type: atom(),
    message: String.t()
  }

  def new(type, message) do
    %__MODULE__{
      type: type,
      message: message
    }
  end
end