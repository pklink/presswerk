defmodule Presswerk.Repo.Migrations.CreatePreorders do
  use Ecto.Migration

  def change do
    create table(:preorders) do
      add :artist, :string, null: false
      add :album, :string, null: false
      add :shop, :string
      add :ordered_at, :date
      add :release_date, :date
      add :status, :string, null: false, default: "preordered"
      add :cover_url, :string
      add :external_url, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:preorders, [:artist, :album])
    create index(:preorders, [:status])
  end
end
