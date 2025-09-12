defmodule PocElixirPhoenix.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias PocElixirPhoenix.Repo

  alias PocElixirPhoenix.Products.Product
  alias PocElixirPhoenix.Categories.Category
  alias PocElixirPhoenix.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any product changes.

  The broadcasted messages match the pattern:

    * {:created, %Product{}}
    * {:updated, %Product{}}
    * {:deleted, %Product{}}

  """
  def subscribe_products(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(PocElixirPhoenix.PubSub, "user:#{key}:products")
  end

  defp broadcast_product(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(PocElixirPhoenix.PubSub, "user:#{key}:products", message)
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products(scope)
      [%Product{}, ...]

  """
  def list_products(%Scope{} = scope) do
    Repo.all_by(Product, user_id: scope.user.id)
    |> Repo.preload(:category)
  end

  @doc """
  Returns a paginated list of products.

  ## Examples

      iex> list_products_paginated(scope, page: 1, per_page: 10)
      %{products: [%Product{}, ...], page: 1, per_page: 10, total_pages: 3, total_count: 26}

  """
  def list_products_paginated(%Scope{} = scope, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    offset = (page - 1) * per_page

    base_query =
      from(p in Product,
        where: p.user_id == ^scope.user.id,
        preload: [:category]
      )

    total_count = Repo.aggregate(base_query, :count, :id)
    total_pages = ceil(total_count / per_page)

    products =
      base_query
      |> limit(^per_page)
      |> offset(^offset)
      |> order_by([p], desc: p.inserted_at)
      |> Repo.all()

    %{
      products: products,
      page: page,
      per_page: per_page,
      total_pages: total_pages,
      total_count: total_count,
      has_prev: page > 1,
      has_next: page < total_pages
    }
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(scope, 123)
      %Product{}

      iex> get_product!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(%Scope{} = scope, id) do
    Repo.get_by!(Product, id: id, user_id: scope.user.id)
    |> Repo.preload(:category)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(scope, %{field: value})
      {:ok, %Product{}}

      iex> create_product(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(%Scope{} = scope, attrs) do
    with {:ok, product = %Product{}} <-
           %Product{}
           |> Product.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_product(scope, {:created, product})
      {:ok, product}
    end
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(scope, product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(scope, product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Scope{} = scope, %Product{} = product, attrs) do
    true = product.user_id == scope.user.id

    with {:ok, product = %Product{}} <-
           product
           |> Product.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_product(scope, {:updated, product})
      {:ok, product}
    end
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(scope, product)
      {:ok, %Product{}}

      iex> delete_product(scope, product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Scope{} = scope, %Product{} = product) do
    true = product.user_id == scope.user.id

    with {:ok, product = %Product{}} <-
           Repo.delete(product) do
      broadcast_product(scope, {:deleted, product})
      {:ok, product}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(scope, product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Scope{} = scope, %Product{} = product, attrs \\ %{}) do
    true = product.user_id == scope.user.id

    Product.changeset(product, attrs, scope)
  end

  @doc """
  Returns the list of categories for the given scope.

  ## Examples

      iex> list_categories_for_select(scope)
      [{"Category Name", 1}, ...]

  """
  def list_categories_for_select(%Scope{} = scope) do
    Repo.all_by(Category, user_id: scope.user.id)
    |> Enum.map(&{&1.name, &1.id})
  end
end
