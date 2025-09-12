defmodule PocElixirPhoenixWeb.ProductLive.Show do
  use PocElixirPhoenixWeb, :live_view

  alias PocElixirPhoenix.Products

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Product {@product.id}
        <:subtitle>This is a product record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/products"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/products/#{@product}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit product
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@product.name}</:item>
        <:item title="Price">{@product.price}</:item>
        <:item title="Category">
          {if @product.category, do: @product.category.name, else: "No category assigned"}
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Products.subscribe_products(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Product")
     |> assign(:product, Products.get_product!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %PocElixirPhoenix.Products.Product{id: id} = product},
        %{assigns: %{product: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :product, product)}
  end

  def handle_info(
        {:deleted, %PocElixirPhoenix.Products.Product{id: id}},
        %{assigns: %{product: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current product was deleted.")
     |> push_navigate(to: ~p"/products")}
  end

  def handle_info({type, %PocElixirPhoenix.Products.Product{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
