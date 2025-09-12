defmodule PocElixirPhoenixWeb.CategoryLive.Show do
  use PocElixirPhoenixWeb, :live_view

  alias PocElixirPhoenix.Categories

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Category {@category.id}
        <:subtitle>This is a category record from your database.</:subtitle>
        
        <:actions>
          <.button navigate={~p"/categories"}><.icon name="hero-arrow-left" /></.button>
          <.button variant="primary" navigate={~p"/categories/#{@category}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit category
          </.button>
        </:actions>
      </.header>
      
      <.list>
        <:item title="Name">{@category.name}</:item>
        
        <:item title="Description">{@category.description}</:item>
        
        <:item title="Products">
          <%= if Enum.empty?(@category.products) do %>
            <span class="text-gray-500">No products in this category</span>
          <% else %>
            <div class="space-y-2">
              <%= for product <- @category.products do %>
                <div class="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <span>{product.name}</span>
                  <span class="text-sm text-gray-600">${product.price}</span>
                </div>
              <% end %>
            </div>
          <% end %>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Categories.subscribe_categories(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Category")
     |> assign(:category, Categories.get_category!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %PocElixirPhoenix.Categories.Category{id: id} = category},
        %{assigns: %{category: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :category, category)}
  end

  def handle_info(
        {:deleted, %PocElixirPhoenix.Categories.Category{id: id}},
        %{assigns: %{category: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current category was deleted.")
     |> push_navigate(to: ~p"/categories")}
  end

  def handle_info({type, %PocElixirPhoenix.Categories.Category{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
