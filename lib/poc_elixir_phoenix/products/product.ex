defmodule PocElixirPhoenix.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :price, :decimal

    belongs_to :category, PocElixirPhoenix.Categories.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :category_id])
    |> validate_required([:name, :price])
    |> foreign_key_constraint(:category_id)
  end
end
