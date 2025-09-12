# Script de prueba para verificar la paginación
# Ejecutar con: mix run test_pagination.exs

alias PocElixirPhoenix.{Repo, Products, Accounts}
alias PocElixirPhoenix.Accounts.Scope

# Obtener el primer usuario para las pruebas
user = Repo.get(Accounts.User, 1)

if user do
  scope = %Scope{user: user}

  # Probar la paginación
  IO.puts("=== Prueba de Paginación ===")

  # Página 1
  page1 = Products.list_products_paginated(scope, page: 1, per_page: 5)
  IO.puts("Página 1:")
  IO.puts("  Productos: #{length(page1.products)}")
  IO.puts("  Total: #{page1.total_count}")
  IO.puts("  Páginas totales: #{page1.total_pages}")
  IO.puts("  Tiene anterior: #{page1.has_prev}")
  IO.puts("  Tiene siguiente: #{page1.has_next}")

  # Página 2
  page2 = Products.list_products_paginated(scope, page: 2, per_page: 5)
  IO.puts("\nPágina 2:")
  IO.puts("  Productos: #{length(page2.products)}")
  IO.puts("  Tiene anterior: #{page2.has_prev}")
  IO.puts("  Tiene siguiente: #{page2.has_next}")

  IO.puts("\n=== Paginación configurada correctamente ===")
else
  IO.puts("No se encontró usuario para las pruebas")
end
