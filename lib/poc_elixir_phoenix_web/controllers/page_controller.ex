defmodule PocElixirPhoenixWeb.PageController do
  use PocElixirPhoenixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
