defmodule PocElixirPhoenixWeb.ProductLive.Index do
  use PocElixirPhoenixWeb, :live_view

  alias PocElixirPhoenix.Products
  alias PocElixirPhoenix.Accounts

  @per_page 10

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Products
        <:subtitle>
          Showing {@pagination.per_page} of {@pagination.total_count} products
        </:subtitle>
        <:actions>
          <.button
            :if={Accounts.can?(@current_scope.user, :create, :product)}
            variant="primary"
            navigate={~p"/products/new"}
          >
            <.icon name="hero-plus" /> New Product
          </.button>
        </:actions>
      </.header>

      <.table
        id="products"
        rows={@streams.products}
        row_click={fn {_id, product} -> JS.navigate(~p"/products/#{product}") end}
      >
        <:col :let={{_id, product}} label="Name">{product.name}</:col>
        <:col :let={{_id, product}} label="Price">{product.price}</:col>
        <:col :let={{_id, product}} label="Category">
          {if product.category, do: product.category.name, else: "No category"}
        </:col>
        <:action :let={{_id, product}}>
          <div class="sr-only">
            <.link navigate={~p"/products/#{product}"}>Show</.link>
          </div>
          <.link
            :if={Accounts.can?(@current_scope.user, :update, :product)}
            navigate={~p"/products/#{product}/edit"}
          >
            Edit
          </.link>
        </:action>
        <:action :let={{id, product}}>
          <.link
            :if={Accounts.can?(@current_scope.user, :delete, :product)}
            phx-click={JS.push("delete", value: %{id: product.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>

      <.pagination_controls pagination={@pagination} />
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      Products.subscribe_products(socket.assigns.current_scope)
    end

    page = String.to_integer(params["page"] || "1")
    pagination = load_products(socket.assigns.current_scope, page)

    {:ok,
     socket
     |> assign(:page_title, "Listing Products")
     |> assign(:pagination, pagination)
     |> stream(:products, pagination.products)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    current_user = socket.assigns.current_scope.user

    case Accounts.authorize(current_user, :delete, :product) do
      :ok ->
        product = Products.get_product!(socket.assigns.current_scope, id)
        {:ok, _} = Products.delete_product(socket.assigns.current_scope, product)

        # Reload current page after deletion
        pagination = load_products(socket.assigns.current_scope, socket.assigns.pagination.page)

        {:noreply,
         socket
         |> assign(:pagination, pagination)
         |> stream(:products, pagination.products, reset: true)}

      {:error, :unauthorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "You don't have permission to delete products.")}
    end
  end

  @impl true
  def handle_event("navigate_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    pagination = load_products(socket.assigns.current_scope, page)

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> stream(:products, pagination.products, reset: true)
     |> push_patch(to: ~p"/products?page=#{page}")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")

    if page != socket.assigns.pagination.page do
      pagination = load_products(socket.assigns.current_scope, page)

      {:noreply,
       socket
       |> assign(:pagination, pagination)
       |> stream(:products, pagination.products, reset: true)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({type, %PocElixirPhoenix.Products.Product{}}, socket)
      when type in [:created, :updated, :deleted] do
    # Reload current page to reflect changes
    pagination = load_products(socket.assigns.current_scope, socket.assigns.pagination.page)

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> stream(:products, pagination.products, reset: true)}
  end

  defp load_products(current_scope, page) do
    Products.list_products_paginated(current_scope, page: page, per_page: @per_page)
  end
end
