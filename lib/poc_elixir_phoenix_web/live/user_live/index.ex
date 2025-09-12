defmodule PocElixirPhoenixWeb.UserLive.Index do
  use PocElixirPhoenixWeb, :live_view

  alias PocElixirPhoenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        User Management
        <:subtitle>Manage users and their roles in the system</:subtitle>
      </.header>
      
      <.table id="users" rows={@users}>
        <:col :let={user} label="Email">{user.email}</:col>
        
        <:col :let={user} label="Role">
          <.badge variant={role_variant(user.role)}>{role_label(user.role)}</.badge>
        </:col>
        
        <:col :let={user} label="Confirmed">{if user.confirmed_at, do: "Yes", else: "No"}</:col>
        
        <:col :let={user} label="Registration Date">
          {Calendar.strftime(user.inserted_at, "%d/%m/%Y")}
        </:col>
        
        <:action :let={user}>
          <.form
            :if={user.id != @current_scope.user.id}
            for={%{}}
            phx-submit="change_role"
            phx-value-user-id={user.id}
            class="inline-flex items-center gap-2"
          >
            <.input
              type="select"
              name="role"
              value={user.role}
              options={role_options()}
              class="text-sm"
            /> <.button type="submit" class="btn-sm">Change</.button>
          </.form>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_scope.user

    case Accounts.authorize(current_user, :index, :user) do
      :ok ->
        users = Accounts.list_users()

        {:ok,
         socket
         |> assign(:page_title, "User Management")
         |> assign(:users, users)}

      {:error, :unauthorized} ->
        {:ok,
         socket
         |> put_flash(:error, "You don't have permission to access this section.")
         |> push_navigate(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("change_role", %{"user-id" => user_id, "role" => new_role}, socket) do
    current_user = socket.assigns.current_scope.user

    case Accounts.authorize(current_user, :update, :user) do
      :ok ->
        user = Accounts.get_user!(user_id)

        case Accounts.update_user_role(user, %{role: new_role}) do
          {:ok, _updated_user} ->
            users = Accounts.list_users()

            {:noreply,
             socket
             |> put_flash(:info, "Role updated successfully")
             |> assign(:users, users)}

          {:error, _changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Error updating role")}
        end

      {:error, :unauthorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "You don't have permission to change roles.")}
    end
  end

  defp role_options do
    [
      {"User", "user"},
      {"Administrator", "admin"},
      {"Superuser", "superuser"}
    ]
  end

  defp role_label("user"), do: "User"
  defp role_label("admin"), do: "Administrator"
  defp role_label("superuser"), do: "Superuser"

  defp role_variant("user"), do: "secondary"
  defp role_variant("admin"), do: "warning"
  defp role_variant("superuser"), do: "destructive"
end
