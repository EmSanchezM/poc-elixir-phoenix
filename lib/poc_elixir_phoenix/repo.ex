defmodule PocElixirPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :poc_elixir_phoenix,
    adapter: Ecto.Adapters.Postgres
end
