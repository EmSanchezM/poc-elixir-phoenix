defmodule PocElixirPhoenixWeb.CategoryLive.Index do
  use PocElixirPhoenixWeb, :live_view

  alias PocElixirPhoenix.Categories

  @per_page 10

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Categories
        <:subtitle>Showing {@pagination.per_page} of {@pagination.total_count} categories</:subtitle>
        
        <:actions>
          <.button variant="primary" navigate={~p"/categories/new"}>
            <.icon name="hero-plus" /> New Category
          </.button>
        </:actions>
      </.header>
      
      <.table
        id="categories"
        rows={@streams.categories}
        row_click={fn {_id, category} -> JS.navigate(~p"/categories/#{category}") end}
      >
        <:col :let={{_id, category}} label="Name">{category.name}</:col>
        
        <:col :let={{_id, category}} label="Description">{category.description}</:col>
        
        <:col :let={{_id, category}} label="Products">
          {length(category.products)} product{if length(category.products) != 1, do: "s"}
        </:col>
        
        <:action :let={{_id, category}}>
          <div class="sr-only"><.link navigate={~p"/categories/#{category}"}>Show</.link></div>
           <.link navigate={~p"/categories/#{category}/edit"}>Edit</.link>
        </:action>
        
        <:action :let={{id, category}}>
          <.link
            phx-click={JS.push("delete", value: %{id: category.id}) |> hide("##{id}")}
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
      Categories.subscribe_categories(socket.assigns.current_scope)
    end

    page = String.to_integer(params["page"] || "1")
    pagination = load_categories(socket.assigns.current_scope, page)

    {:ok,
     socket
     |> assign(:page_title, "Listing Categories")
     |> assign(:pagination, pagination)
     |> stream(:categories, pagination.categories)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Categories.get_category!(socket.assigns.current_scope, id)
    {:ok, _} = Categories.delete_category(socket.assigns.current_scope, category)

    # Reload current page after deletion
    pagination = load_categories(socket.assigns.current_scope, socket.assigns.pagination.page)

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> stream(:categories, pagination.categories, reset: true)}
  end

  @impl true
  def handle_event("navigate_page", %{"page" => page}, socket) do
    page = String.to_integer(page)
    pagination = load_categories(socket.assigns.current_scope, page)

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> stream(:categories, pagination.categories, reset: true)
     |> push_patch(to: ~p"/categories?page=#{page}")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")

    if page != socket.assigns.pagination.page do
      pagination = load_categories(socket.assigns.current_scope, page)

      {:noreply,
       socket
       |> assign(:pagination, pagination)
       |> stream(:categories, pagination.categories, reset: true)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({type, %PocElixirPhoenix.Categories.Category{}}, socket)
      when type in [:created, :updated, :deleted] do
    # Reload current page to reflect changes
    pagination = load_categories(socket.assigns.current_scope, socket.assigns.pagination.page)

    {:noreply,
     socket
     |> assign(:pagination, pagination)
     |> stream(:categories, pagination.categories, reset: true)}
  end

  defp load_categories(current_scope, page) do
    Categories.list_categories_paginated(current_scope, page: page, per_page: @per_page)
  end
end
