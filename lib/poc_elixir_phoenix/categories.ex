defmodule PocElixirPhoenix.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias PocElixirPhoenix.Repo

  alias PocElixirPhoenix.Categories.Category
  alias PocElixirPhoenix.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any category changes.

  The broadcasted messages match the pattern:

    * {:created, %Category{}}
    * {:updated, %Category{}}
    * {:deleted, %Category{}}

  """
  def subscribe_categories(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(PocElixirPhoenix.PubSub, "user:#{key}:categories")
  end

  defp broadcast_category(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(PocElixirPhoenix.PubSub, "user:#{key}:categories", message)
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories(scope)
      [%Category{}, ...]

  """
  def list_categories(%Scope{} = scope) do
    Repo.all_by(Category, user_id: scope.user.id)
    |> Repo.preload(:products)
  end

  @doc """
  Returns a paginated list of categories.

  ## Examples

      iex> list_categories_paginated(scope, page: 1, per_page: 10)
      %{categories: [%Category{}, ...], page: 1, per_page: 10, total_pages: 3, total_count: 26}

  """
  def list_categories_paginated(%Scope{} = scope, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    offset = (page - 1) * per_page

    base_query =
      from(c in Category,
        where: c.user_id == ^scope.user.id,
        preload: [:products]
      )

    total_count = Repo.aggregate(base_query, :count, :id)
    total_pages = ceil(total_count / per_page)

    categories =
      base_query
      |> limit(^per_page)
      |> offset(^offset)
      |> order_by([c], desc: c.inserted_at)
      |> Repo.all()

    %{
      categories: categories,
      page: page,
      per_page: per_page,
      total_pages: total_pages,
      total_count: total_count,
      has_prev: page > 1,
      has_next: page < total_pages
    }
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(scope, 123)
      %Category{}

      iex> get_category!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(%Scope{} = scope, id) do
    Repo.get_by!(Category, id: id, user_id: scope.user.id)
    |> Repo.preload(:products)
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(scope, %{field: value})
      {:ok, %Category{}}

      iex> create_category(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(%Scope{} = scope, attrs) do
    with {:ok, category = %Category{}} <-
           %Category{}
           |> Category.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_category(scope, {:created, category})
      {:ok, category}
    end
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(scope, category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(scope, category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Scope{} = scope, %Category{} = category, attrs) do
    true = category.user_id == scope.user.id

    with {:ok, category = %Category{}} <-
           category
           |> Category.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_category(scope, {:updated, category})
      {:ok, category}
    end
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(scope, category)
      {:ok, %Category{}}

      iex> delete_category(scope, category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Scope{} = scope, %Category{} = category) do
    true = category.user_id == scope.user.id

    with {:ok, category = %Category{}} <-
           Repo.delete(category) do
      broadcast_category(scope, {:deleted, category})
      {:ok, category}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(scope, category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Scope{} = scope, %Category{} = category, attrs \\ %{}) do
    true = category.user_id == scope.user.id

    Category.changeset(category, attrs, scope)
  end
end
