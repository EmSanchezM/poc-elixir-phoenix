defmodule PocElixirPhoenixWeb.CategoryLive.Form do
  use PocElixirPhoenixWeb, :live_view

  alias PocElixirPhoenix.Categories
  alias PocElixirPhoenix.Categories.Category
  alias PocElixirPhoenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage category records in your database.</:subtitle>
      </.header>
      
      <.form for={@form} id="category-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Category</.button>
          <.button navigate={return_path(@current_scope, @return_to, @category)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    current_user = socket.assigns.current_scope.user
    action = socket.assigns.live_action

    # Check permissions based on action
    permission_action = if action == :new, do: :create, else: :update

    case Accounts.authorize(current_user, permission_action, :category) do
      :ok ->
        {:ok,
         socket
         |> assign(:return_to, return_to(params["return_to"]))
         |> apply_action(action, params)}

      {:error, :unauthorized} ->
        {:ok,
         socket
         |> put_flash(:error, "You don't have permission to perform this action.")
         |> push_navigate(to: ~p"/categories")}
    end
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    category = Categories.get_category!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, category)
    |> assign(:form, to_form(Categories.change_category(socket.assigns.current_scope, category)))
  end

  defp apply_action(socket, :new, _params) do
    category = %Category{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, category)
    |> assign(:form, to_form(Categories.change_category(socket.assigns.current_scope, category)))
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      Categories.change_category(
        socket.assigns.current_scope,
        socket.assigns.category,
        category_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.live_action, category_params)
  end

  defp save_category(socket, :edit, category_params) do
    current_user = socket.assigns.current_scope.user

    case Accounts.authorize(current_user, :update, :category) do
      :ok ->
        case Categories.update_category(
               socket.assigns.current_scope,
               socket.assigns.category,
               category_params
             ) do
          {:ok, category} ->
            {:noreply,
             socket
             |> put_flash(:info, "Category updated successfully")
             |> push_navigate(
               to: return_path(socket.assigns.current_scope, socket.assigns.return_to, category)
             )}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      {:error, :unauthorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "You don't have permission to update categories.")}
    end
  end

  defp save_category(socket, :new, category_params) do
    current_user = socket.assigns.current_scope.user

    case Accounts.authorize(current_user, :create, :category) do
      :ok ->
        case Categories.create_category(socket.assigns.current_scope, category_params) do
          {:ok, category} ->
            {:noreply,
             socket
             |> put_flash(:info, "Category created successfully")
             |> push_navigate(
               to: return_path(socket.assigns.current_scope, socket.assigns.return_to, category)
             )}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      {:error, :unauthorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "You don't have permission to create categories.")}
    end
  end

  defp return_path(_scope, "index", _category), do: ~p"/categories"
  defp return_path(_scope, "show", category), do: ~p"/categories/#{category}"
end
