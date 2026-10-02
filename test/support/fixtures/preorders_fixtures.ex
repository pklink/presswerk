defmodule Presswerk.PreordersFixtures do
  @moduledoc false

  def preorder_fixture(attrs \\ %{}) do
    {:ok, preorder} =
      attrs
      |> Enum.into(%{
        artist: "Artist #{System.unique_integer([:positive])}",
        album: "Album #{System.unique_integer([:positive])}"
      })
      |> Presswerk.Preorders.create_preorder()

    preorder
  end
end
