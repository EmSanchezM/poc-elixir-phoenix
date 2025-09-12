defmodule PocElixirPhoenix.Repo.Migrations.AddCategoryToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :category_id, references(:categories, type: :id, on_delete: :nilify_all)
    end

    create index(:products, [:category_id])
  end
end
