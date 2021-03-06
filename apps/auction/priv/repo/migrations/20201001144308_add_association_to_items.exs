defmodule Auction.Repo.Migrations.AddAssociationToItems do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :user_id, references(:users)
    end

    create index(:items, [:user_id])
  end
end
