defmodule Presswerk.Preorders.Preorder do
  @moduledoc "Schema and changeset for vinyl preorders."
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
    field :article_url, :string
    field :order_url, :string
    field :notes, :string
    field :price, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc "Returns the list of all available statuses."
  def statuses, do: @statuses

  @doc "Statuses that count as \"open\"."
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
      :article_url,
      :order_url,
      :notes,
      :price
    ])
    |> update_change(:artist, &trim_artist/1)
    |> update_change(:album, &trim/1)
    |> validate_required([:album, :status])
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_change(:price, fn _field, value -> validate_price_scale(value) end)
    |> unique_constraint([:artist, :album],
      name: :preorders_artist_album_index,
      message: "This record has already been added."
    )
  end

  @doc false
  defp trim_artist(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      artist -> artist
    end
  end

  defp trim_artist(value), do: value

  @doc false
  defp trim(value) when is_binary(value), do: String.trim(value)
  defp trim(value), do: value

  @doc false
  defp validate_price_scale(%Decimal{exp: exp}) do
    scale = -exp

    if scale <= 2 do
      []
    else
      [price: "Price must have at most 2 decimal places"]
    end
  end

  @doc false
  defp validate_price_scale(_value), do: []
end
