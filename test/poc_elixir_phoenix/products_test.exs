defmodule PocElixirPhoenix.ProductsTest do
  use PocElixirPhoenix.DataCase

  alias PocElixirPhoenix.Products

  describe "products" do
    alias PocElixirPhoenix.Products.Product

    import PocElixirPhoenix.AccountsFixtures, only: [user_scope_fixture: 0]
    import PocElixirPhoenix.ProductsFixtures

    @invalid_attrs %{name: nil, price: nil}

    test "list_products/1 returns all products" do
      scope = user_scope_fixture()
      _product1 = product_fixture(scope, %{name: "Product 1"})
      _product2 = product_fixture(scope, %{name: "Product 2"})

      products = Products.list_products(scope)
      assert length(products) >= 2
      assert Enum.any?(products, &(&1.name == "Product 1"))
      assert Enum.any?(products, &(&1.name == "Product 2"))
    end

    test "get_product!/2 returns the product with given id" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      retrieved_product = Products.get_product!(scope, product.id)

      assert retrieved_product.id == product.id
      assert retrieved_product.name == product.name
      assert retrieved_product.price == product.price
    end

    test "create_product/2 with valid data creates a product" do
      valid_attrs = %{name: "some name", price: "120.5"}
      scope = user_scope_fixture()

      assert {:ok, %Product{} = product} = Products.create_product(scope, valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
    end

    test "create_product/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.create_product(scope, @invalid_attrs)
    end

    test "update_product/3 with valid data updates the product" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      update_attrs = %{name: "some updated name", price: "456.7"}

      assert {:ok, %Product{} = product} = Products.update_product(scope, product, update_attrs)
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
    end

    test "update_product/3 works with any scope" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      update_attrs = %{name: "updated by other scope"}

      assert {:ok, %Product{} = updated_product} =
               Products.update_product(other_scope, product, update_attrs)

      assert updated_product.name == "updated by other scope"
    end

    test "update_product/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Products.update_product(scope, product, @invalid_attrs)

      # Verify the product wasn't changed
      unchanged_product = Products.get_product!(scope, product.id)
      assert unchanged_product.name == product.name
      assert unchanged_product.price == product.price
    end

    test "delete_product/2 deletes the product" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:ok, %Product{}} = Products.delete_product(scope, product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(scope, product.id) end
    end

    test "delete_product/2 works with any scope" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)

      assert {:ok, %Product{}} = Products.delete_product(other_scope, product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(scope, product.id) end
    end

    test "change_product/2 returns a product changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert %Ecto.Changeset{} = Products.change_product(scope, product)
    end
  end
end
