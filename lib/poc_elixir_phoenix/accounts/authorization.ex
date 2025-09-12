defmodule PocElixirPhoenix.Accounts.Authorization do
  @moduledoc """
  Authorization helpers for checking user permissions.
  """

  alias PocElixirPhoenix.Accounts.User

  @doc """
  Checks if a user can perform a specific action on a resource.
  """
  def can?(user, action, resource)

  # Product permissions
  def can?(%User{} = user, :create, :product), do: User.can_manage_products?(user)
  def can?(%User{} = user, :update, :product), do: User.can_manage_products?(user)
  def can?(%User{} = user, :delete, :product), do: User.can_manage_products?(user)
  def can?(%User{} = user, :view, :product), do: User.can_view_products?(user)
  def can?(%User{} = user, :index, :product), do: User.can_view_products?(user)

  # Category permissions
  def can?(%User{} = user, :create, :category), do: User.can_manage_categories?(user)
  def can?(%User{} = user, :update, :category), do: User.can_manage_categories?(user)
  def can?(%User{} = user, :delete, :category), do: User.can_manage_categories?(user)
  def can?(%User{} = user, :view, :category), do: User.can_view_categories?(user)
  def can?(%User{} = user, :index, :category), do: User.can_view_categories?(user)

  # User management permissions (only superuser can manage users)
  def can?(%User{} = user, :create, :user), do: User.superuser?(user)
  def can?(%User{} = user, :update, :user), do: User.superuser?(user)
  def can?(%User{} = user, :delete, :user), do: User.superuser?(user)
  def can?(%User{} = user, :view, :user), do: User.admin?(user)
  def can?(%User{} = user, :index, :user), do: User.admin?(user)

  # Default deny
  def can?(_, _, _), do: false

  @doc """
  Raises an exception if the user doesn't have permission.
  """
  def authorize!(user, action, resource) do
    if can?(user, action, resource) do
      :ok
    else
      raise PocElixirPhoenix.Accounts.UnauthorizedError,
        message: "User does not have permission to #{action} #{resource}"
    end
  end

  @doc """
  Returns an error tuple if the user doesn't have permission.
  """
  def authorize(user, action, resource) do
    if can?(user, action, resource) do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
