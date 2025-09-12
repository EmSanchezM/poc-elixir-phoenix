defmodule PocElixirPhoenix.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :price, :decimal
    field :user_id, :id

    belongs_to :category, PocElixirPhoenix.Categories.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs, user_scope) do
    product
    |> cast(attrs, [:name, :price, :category_id])
    |> validate_required([:name, :price])
    |> put_change(:user_id, user_scope.user.id)
    |> foreign_key_constraint(:category_id)
  end
end
