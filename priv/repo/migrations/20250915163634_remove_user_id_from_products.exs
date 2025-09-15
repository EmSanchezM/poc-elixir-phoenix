defmodule PocElixirPhoenix.Repo.Migrations.RemoveUserIdFromProducts do
  use Ecto.Migration

  def change do
    # Eliminar el índice primero
    drop index(:products, [:user_id])

    # Eliminar la columna user_id (esto también elimina la foreign key constraint)
    alter table(:products) do
      remove :user_id, references(:users, type: :id, on_delete: :delete_all)
    end
  end
end
