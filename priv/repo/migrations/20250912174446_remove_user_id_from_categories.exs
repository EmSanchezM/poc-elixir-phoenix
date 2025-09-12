defmodule PocElixirPhoenix.Repo.Migrations.RemoveUserIdFromCategories do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      remove :user_id, :integer
    end
  end
end
