defmodule Presswerk.Repo.Migrations.AddPriceToPreorders do
  use Ecto.Migration

  def change do
    alter table(:preorders) do
      add :price, :decimal, precision: 10, scale: 2
    end
  end
end
