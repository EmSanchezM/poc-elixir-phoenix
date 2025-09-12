defmodule PocElixirPhoenix.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :user_id, :id

    has_many :products, PocElixirPhoenix.Products.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs, user_scope) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:description, max: 500)
    |> put_change(:user_id, user_scope.user.id)
  end
end
