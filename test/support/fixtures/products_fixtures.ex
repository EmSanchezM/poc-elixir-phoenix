defmodule PocElixirPhoenix.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PocElixirPhoenix.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        price: "120.5"
      })

    {:ok, product} = PocElixirPhoenix.Products.create_product(scope, attrs)
    product
  end
end
