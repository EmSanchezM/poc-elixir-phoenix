defmodule PocElixirPhoenix.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string

    has_many :products, PocElixirPhoenix.Products.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:description, max: 500)
  end
end
