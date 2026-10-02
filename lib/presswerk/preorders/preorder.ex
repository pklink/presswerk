defmodule Presswerk.Preorders.Preorder do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:preordered, :shipped, :received, :cancelled]

  schema "preorders" do
    field :artist, :string
    field :album, :string
    field :shop, :string
    field :ordered_at, :date
    field :release_date, :date
    field :status, Ecto.Enum, values: @statuses, default: :preordered
    field :cover_url, :string
    field :external_url, :string
    field :notes, :string

    timestamps(type: :utc_datetime)
  end

  def statuses, do: @statuses

  @doc "Stati, die als \"offen\" gelten."
  def open_statuses, do: [:preordered, :shipped]

  @doc false
  def changeset(preorder, attrs) do
    preorder
    |> cast(attrs, [
      :artist,
      :album,
      :shop,
      :ordered_at,
      :release_date,
      :status,
      :cover_url,
      :external_url,
      :notes
    ])
    |> update_change(:artist, &trim/1)
    |> update_change(:album, &trim/1)
    |> validate_required([:artist, :album, :status])
    |> unique_constraint([:artist, :album],
      name: :preorders_artist_album_index,
      message: "Diese Platte wurde bereits erfasst."
    )
  end

  defp trim(value) when is_binary(value), do: String.trim(value)
  defp trim(value), do: value
end
