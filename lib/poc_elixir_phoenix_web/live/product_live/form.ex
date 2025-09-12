defmodule PocElixirPhoenixWeb.ProductLive.Form do
  use PocElixirPhoenixWeb, :live_view

  alias PocElixirPhoenix.Products
  alias PocElixirPhoenix.Products.Product
  alias PocElixirPhoenix.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="product-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:price]} type="number" label="Price" step="any" />
        <.input
          field={@form[:category_id]}
          type="select"
          label="Category"
          options={[{"Select a category", ""} | @categories]}
          prompt="Select a category"
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Product</.button>
          <.button navigate={return_path(@current_scope, @return_to, @product)}>Cancel</.button>
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

    case Accounts.authorize(current_user, permission_action, :product) do
      :ok ->
        {:ok,
         socket
         |> assign(:return_to, return_to(params["return_to"]))
         |> apply_action(action, params)}

      {:error, :unauthorized} ->
        {:ok,
         socket
         |> put_flash(:error, "You don't have permission to perform this action.")
         |> push_navigate(to: ~p"/products")}
    end
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    product = Products.get_product!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, product)
    |> assign(:categories, Products.list_categories_for_select(socket.assigns.current_scope))
    |> assign(:form, to_form(Products.change_product(socket.assigns.current_scope, product)))
  end

  defp apply_action(socket, :new, _params) do
    product = %Product{}

    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, product)
    |> assign(:categories, Products.list_categories_for_select(socket.assigns.current_scope))
    |> assign(:form, to_form(Products.change_product(socket.assigns.current_scope, product)))
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      Products.change_product(
        socket.assigns.current_scope,
        socket.assigns.product,
        product_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.live_action, product_params)
  end

  defp save_product(socket, :edit, product_params) do
    current_user = socket.assigns.current_scope.user

    case Accounts.authorize(current_user, :update, :product) do
      :ok ->
        case Products.update_product(
               socket.assigns.current_scope,
               socket.assigns.product,
               product_params
             ) do
          {:ok, product} ->
            {:noreply,
             socket
             |> put_flash(:info, "Product updated successfully")
             |> push_navigate(
               to: return_path(socket.assigns.current_scope, socket.assigns.return_to, product)
             )}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      {:error, :unauthorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "You don't have permission to update products.")}
    end
  end

  defp save_product(socket, :new, product_params) do
    current_user = socket.assigns.current_scope.user

    case Accounts.authorize(current_user, :create, :product) do
      :ok ->
        case Products.create_product(socket.assigns.current_scope, product_params) do
          {:ok, product} ->
            {:noreply,
             socket
             |> put_flash(:info, "Product created successfully")
             |> push_navigate(
               to: return_path(socket.assigns.current_scope, socket.assigns.return_to, product)
             )}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      {:error, :unauthorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "You don't have permission to create products.")}
    end
  end

  defp return_path(_scope, "index", _product), do: ~p"/products"
  defp return_path(_scope, "show", product), do: ~p"/products/#{product}"
end
