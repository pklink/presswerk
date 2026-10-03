defmodule Presswerk.Repo.Migrations.MakeArtistOptional do
  use Ecto.Migration

  def up, do: copy_preorders(true)
  def down, do: copy_preorders(false)

  defp copy_preorders(nullable_artist) do
    create table(:preorders_copy) do
      add :artist, :string, null: nullable_artist
      add :album, :string, null: false
      add :shop, :string
      add :ordered_at, :date
      add :release_date, :date
      add :status, :string, null: false, default: "preordered"
      add :cover_url, :string
      add :article_url, :string
      add :order_url, :string
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    artist = if nullable_artist, do: "NULLIF(artist, '')", else: "COALESCE(artist, '')"

    execute("""
    INSERT INTO preorders_copy
      (id, artist, album, shop, ordered_at, release_date, status, cover_url,
       article_url, order_url, notes, inserted_at, updated_at)
    SELECT id, #{artist}, album, shop, ordered_at, release_date, status, cover_url,
           article_url, order_url, notes, inserted_at, updated_at
    FROM preorders
    """)

    drop table(:preorders)
    rename table(:preorders_copy), to: table(:preorders)

    if nullable_artist do
      create unique_index(:preorders, ["(coalesce(artist, ''))", :album],
               name: :preorders_artist_album_index
             )
    else
      create unique_index(:preorders, [:artist, :album])
    end

    create index(:preorders, [:status])
  end
end
