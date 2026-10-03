defmodule Presswerk.Repo.Migrations.RenameExternalUrlAndAddOrderUrl do
  use Ecto.Migration

  def change do
    rename table(:preorders), :external_url, to: :article_url

    alter table(:preorders) do
      add :order_url, :string
    end
  end
end
