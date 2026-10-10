defmodule Presswerk.Preorders do
  @moduledoc """
  Manages vinyl preorders.
  """

  import Ecto.Query, warn: false

  alias Presswerk.Repo
  alias Presswerk.Preorders.Preorder

  @doc """
  Lists preorders.

  Options:

    * `:search` - Substring in artist or album
    * `:status` - Status as atom or string (empty/`"all"` = all)
    * `:sort` - `:release_date` (default) or `:artist`
  """
  def list_preorders(opts \\ []) do
    Preorder
    |> filter_search(opts[:search])
    |> filter_status(opts[:status])
    |> sort(opts[:sort])
    |> Repo.all()
  end

  defp filter_search(query, term) when is_binary(term) do
    case String.trim(term) do
      "" ->
        query

      term ->
        pattern = "%" <> escape_like(term) <> "%"

        where(
          query,
          [p],
          like(p.artist, ^pattern) or like(p.album, ^pattern)
        )
    end
  end

  defp filter_search(query, _), do: query

  defp escape_like(term), do: String.replace(term, ~r/([\\%_])/, "\\\\\\1")

  defp filter_status(query, status) when status in ["", "all", nil], do: query

  defp filter_status(query, status) do
    where(query, [p], p.status == ^to_status(status))
  end

  defp to_status(status) when is_atom(status), do: status
  defp to_status(status) when is_binary(status), do: String.to_existing_atom(status)

  # Entries without a release date are sorted last.
  defp sort(query, :artist) do
    order_by(query, [p], asc: fragment("lower(?)", p.artist), asc: fragment("lower(?)", p.album))
  end

  defp sort(query, _release_date) do
    order_by(query, [p],
      asc: is_nil(p.release_date),
      asc: p.release_date,
      asc: fragment("lower(?)", p.artist)
    )
  end

  @doc "Gets a single preorder by ID. Raises if not found."
  def get_preorder!(id), do: Repo.get!(Preorder, id)

  @doc "Creates a preorder from the given attributes."
  def create_preorder(attrs) do
    %Preorder{}
    |> Preorder.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a preorder with the given attributes."
  def update_preorder(%Preorder{} = preorder, attrs) do
    preorder
    |> Preorder.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a preorder."
  def delete_preorder(%Preorder{} = preorder), do: Repo.delete(preorder)

  @doc "Returns a changeset for the given preorder and attributes."
  def change_preorder(%Preorder{} = preorder, attrs \\ %{}) do
    Preorder.changeset(preorder, attrs)
  end

  @doc """
  Dashboard statistics: `%{open: n, received: n, cancelled: n}`.
  """
  def stats do
    counts =
      Preorder
      |> group_by([p], p.status)
      |> select([p], {p.status, count(p.id)})
      |> Repo.all()
      |> Map.new()

    %{
      open: Enum.sum(for s <- Preorder.open_statuses(), do: Map.get(counts, s, 0)),
      received: Map.get(counts, :received, 0),
      cancelled: Map.get(counts, :cancelled, 0)
    }
  end

  @doc """
  Open preorders with a release date, grouped by month.

  Returns `[{%Date{day: 1}, [preorder, ...]}, ...]` sorted ascending.
  """
  def upcoming_by_month do
    Preorder
    |> where([p], p.status in ^Preorder.open_statuses() and not is_nil(p.release_date))
    |> order_by([p], asc: p.release_date, asc: fragment("lower(?)", p.artist))
    |> Repo.all()
    |> Enum.chunk_by(&{&1.release_date.year, &1.release_date.month})
    |> Enum.map(fn [first | _] = group ->
      {Date.beginning_of_month(first.release_date), group}
    end)
  end
end
