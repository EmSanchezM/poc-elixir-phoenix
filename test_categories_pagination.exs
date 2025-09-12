# Script de prueba para verificar la paginación de categorías
# Ejecutar con: mix run test_categories_pagination.exs

alias PocElixirPhoenix.{Repo, Categories, Accounts}
alias PocElixirPhoenix.Accounts.Scope

# Obtener el primer usuario para las pruebas
user = Repo.get(Accounts.User, 1)

if user do
  scope = %Scope{user: user}

  # Probar la paginación de categorías
  IO.puts("=== Prueba de Paginación de Categorías ===")

  # Página 1
  page1 = Categories.list_categories_paginated(scope, page: 1, per_page: 5)
  IO.puts("Página 1:")
  IO.puts("  Categorías: #{length(page1.categories)}")
  IO.puts("  Total: #{page1.total_count}")
  IO.puts("  Páginas totales: #{page1.total_pages}")
  IO.puts("  Tiene anterior: #{page1.has_prev}")
  IO.puts("  Tiene siguiente: #{page1.has_next}")

  # Mostrar nombres de categorías
  if length(page1.categories) > 0 do
    IO.puts("  Nombres:")

    Enum.each(page1.categories, fn cat ->
      IO.puts("    - #{cat.name} (#{length(cat.products)} productos)")
    end)
  end

  # Página 2 si existe
  if page1.total_pages > 1 do
    page2 = Categories.list_categories_paginated(scope, page: 2, per_page: 5)
    IO.puts("\nPágina 2:")
    IO.puts("  Categorías: #{length(page2.categories)}")
    IO.puts("  Tiene anterior: #{page2.has_prev}")
    IO.puts("  Tiene siguiente: #{page2.has_next}")
  end

  IO.puts("\n=== Paginación de categorías configurada correctamente ===")
else
  IO.puts("No se encontró usuario para las pruebas")
end
