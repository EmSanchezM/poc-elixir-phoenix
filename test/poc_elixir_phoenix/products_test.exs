defmodule PocElixirPhoenix.ProductsTest do
  use PocElixirPhoenix.DataCase

  alias PocElixirPhoenix.Products

  describe "products" do
    alias PocElixirPhoenix.Products.Product

    import PocElixirPhoenix.AccountsFixtures, only: [user_scope_fixture: 0]
    import PocElixirPhoenix.ProductsFixtures

    @invalid_attrs %{name: nil, price: nil}

    test "list_products/1 returns all scoped products" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      other_product = product_fixture(other_scope)
      assert Products.list_products(scope) == [product]
      assert Products.list_products(other_scope) == [other_product]
    end

    test "get_product!/2 returns the product with given id" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      other_scope = user_scope_fixture()
      assert Products.get_product!(scope, product.id) == product
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(other_scope, product.id) end
    end

    test "create_product/2 with valid data creates a product" do
      valid_attrs = %{name: "some name", price: "120.5"}
      scope = user_scope_fixture()

      assert {:ok, %Product{} = product} = Products.create_product(scope, valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
      assert product.user_id == scope.user.id
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

    test "update_product/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)

      assert_raise MatchError, fn ->
        Products.update_product(other_scope, product, %{})
      end
    end

    test "update_product/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Products.update_product(scope, product, @invalid_attrs)
      assert product == Products.get_product!(scope, product.id)
    end

    test "delete_product/2 deletes the product" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:ok, %Product{}} = Products.delete_product(scope, product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(scope, product.id) end
    end

    test "delete_product/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      assert_raise MatchError, fn -> Products.delete_product(other_scope, product) end
    end

    test "change_product/2 returns a product changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert %Ecto.Changeset{} = Products.change_product(scope, product)
    end
  end
end
