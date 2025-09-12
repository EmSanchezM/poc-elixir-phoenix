defmodule PocElixirPhoenix.Accounts.UnauthorizedError do
  @moduledoc """
  Exception raised when a user tries to perform an unauthorized action.
  """

  defexception [:message]

  def exception(opts) do
    message = Keyword.get(opts, :message, "Unauthorized")
    %__MODULE__{message: message}
  end
end
