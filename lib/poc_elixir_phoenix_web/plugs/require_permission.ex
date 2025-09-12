defmodule PocElixirPhoenixWeb.Plugs.RequirePermission do
  @moduledoc """
  Plug to require specific permissions for accessing routes.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias PocElixirPhoenix.Accounts

  def init(opts), do: opts

  def call(conn, opts) do
    action = Keyword.get(opts, :action)
    resource = Keyword.get(opts, :resource)
    current_user = conn.assigns[:current_user]

    if current_user && Accounts.can?(current_user, action, resource) do
      conn
    else
      conn
      |> put_flash(:error, "No tienes permisos para realizar esta acción.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
