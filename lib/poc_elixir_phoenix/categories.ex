defmodule PocElixirPhoenix.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias PocElixirPhoenix.Repo

  alias PocElixirPhoenix.Categories.Category
  alias PocElixirPhoenix.Accounts.Scope

  @doc """
  Subscribes to notifications about any category changes.

  The broadcasted messages match the pattern:

    * {:created, %Category{}}
    * {:updated, %Category{}}
    * {:deleted, %Category{}}

  """
  def subscribe_categories(%Scope{} = _scope) do
    Phoenix.PubSub.subscribe(PocElixirPhoenix.PubSub, "categories")
  end

  defp broadcast_category(message) do
    Phoenix.PubSub.broadcast(PocElixirPhoenix.PubSub, "categories", message)
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories(scope)
      [%Category{}, ...]

  """
  def list_categories(%Scope{} = _scope) do
    Repo.all(Category)
    |> Repo.preload(:products)
  end

  @doc """
  Returns a paginated list of categories.

  ## Examples

      iex> list_categories_paginated(scope, page: 1, per_page: 10)
      %{categories: [%Category{}, ...], page: 1, per_page: 10, total_pages: 3, total_count: 26}

  """
  def list_categories_paginated(%Scope{} = _scope, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    offset = (page - 1) * per_page

    base_query =
      from(c in Category,
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
  def get_category!(%Scope{} = _scope, id) do
    Repo.get!(Category, id)
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
  def create_category(%Scope{} = _scope, attrs) do
    with {:ok, category = %Category{}} <-
           %Category{}
           |> Category.changeset(attrs)
           |> Repo.insert() do
      broadcast_category({:created, category})
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
  def update_category(%Scope{} = _scope, %Category{} = category, attrs) do
    with {:ok, category = %Category{}} <-
           category
           |> Category.changeset(attrs)
           |> Repo.update() do
      broadcast_category({:updated, category})
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
  def delete_category(%Scope{} = _scope, %Category{} = category) do
    with {:ok, category = %Category{}} <-
           Repo.delete(category) do
      broadcast_category({:deleted, category})
      {:ok, category}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(scope, category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Scope{} = _scope, %Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
