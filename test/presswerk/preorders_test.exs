defmodule Presswerk.PreordersTest do
  use Presswerk.DataCase, async: true

  import Presswerk.PreordersFixtures

  alias Presswerk.Preorders
  alias Presswerk.Preorders.Preorder

  @valid %{artist: "Boygenius", album: "The Record"}

  describe "create_preorder/1" do
    test "legt mit Pflichtfeldern an, Status ist :preordered" do
      assert {:ok, %Preorder{} = p} = Preorders.create_preorder(@valid)
      assert p.artist == "Boygenius"
      assert p.status == :preordered
    end

    test "speichert optionale Felder" do
      attrs =
        Map.merge(@valid, %{
          shop: "Bandcamp",
          ordered_at: ~D[2026-10-01],
          release_date: ~D[2026-11-20],
          status: :shipped,
          notes: "Splatter"
        })

      assert {:ok, p} = Preorders.create_preorder(attrs)
      assert p.shop == "Bandcamp"
      assert p.release_date == ~D[2026-11-20]
      assert p.status == :shipped
    end

    test "Artist und Album sind Pflicht" do
      assert {:error, cs} = Preorders.create_preorder(%{})
      assert %{artist: ["can't be blank"], album: ["can't be blank"]} = errors_on(cs)
    end

    test "ungültiger Status wird abgelehnt" do
      assert {:error, cs} = Preorders.create_preorder(Map.put(@valid, :status, "kaputt"))
      assert %{status: [_]} = errors_on(cs)
    end

    test "Dublette wird mit freundlicher Meldung abgelehnt" do
      assert {:ok, _} = Preorders.create_preorder(@valid)
      assert {:error, cs} = Preorders.create_preorder(@valid)
      assert %{artist: ["This record has already been added."]} = errors_on(cs)
    end

    test "gleicher Artist mit anderem Album ist erlaubt" do
      assert {:ok, _} = Preorders.create_preorder(@valid)
      assert {:ok, _} = Preorders.create_preorder(%{@valid | album: "Anderes"})
    end
  end

  describe "update_preorder/2" do
    test "aktualisiert" do
      p = preorder_fixture()
      assert {:ok, p} = Preorders.update_preorder(p, %{status: :received, shop: "Shop"})
      assert p.status == :received
      assert Preorders.get_preorder!(p.id).shop == "Shop"
    end

    test "validiert und schützt vor Dubletten" do
      a = preorder_fixture()
      b = preorder_fixture()
      assert {:error, _} = Preorders.update_preorder(b, %{artist: ""})

      assert {:error, cs} = Preorders.update_preorder(b, %{artist: a.artist, album: a.album})
      assert %{artist: ["This record has already been added."]} = errors_on(cs)
    end
  end

  test "delete_preorder/1 löscht" do
    p = preorder_fixture()
    assert {:ok, _} = Preorders.delete_preorder(p)
    assert_raise Ecto.NoResultsError, fn -> Preorders.get_preorder!(p.id) end
  end

  describe "list_preorders/1" do
    setup do
      a = preorder_fixture(%{artist: "Zebra", album: "Eins", release_date: ~D[2026-12-01]})

      b =
        preorder_fixture(%{
          artist: "alpha",
          album: "Zwei",
          release_date: ~D[2026-11-01],
          status: :received
        })

      c = preorder_fixture(%{artist: "Mitte", album: "Drei"})
      %{a: a, b: b, c: c}
    end

    test "sortiert nach Release-Datum, ohne Datum zuletzt", %{a: a, b: b, c: c} do
      assert Enum.map(Preorders.list_preorders(), & &1.id) == [b.id, a.id, c.id]
    end

    test "sortiert nach Artist (ohne Groß-/Kleinschreibung)", %{a: a, b: b, c: c} do
      assert Enum.map(Preorders.list_preorders(sort: :artist), & &1.id) == [b.id, c.id, a.id]
    end

    test "sucht in Artist und Album", %{a: a, c: c} do
      assert [%{id: id}] = Preorders.list_preorders(search: "zebra")
      assert id == a.id
      assert [%{id: id}] = Preorders.list_preorders(search: "drei")
      assert id == c.id
      assert Preorders.list_preorders(search: "nix") == []
    end

    test "Suche behandelt % und _ wörtlich" do
      assert Preorders.list_preorders(search: "%") == []
    end

    test "filtert nach Status", %{b: b} do
      assert [%{id: id}] = Preorders.list_preorders(status: "received")
      assert id == b.id
      assert length(Preorders.list_preorders(status: "all")) == 3
    end
  end

  describe "Dashboard" do
    test "stats/0 zählt offen (vorbestellt + versendet), erhalten, storniert" do
      preorder_fixture(%{status: :preordered})
      preorder_fixture(%{status: :shipped})
      preorder_fixture(%{status: :received})
      preorder_fixture(%{status: :cancelled})
      preorder_fixture(%{status: :cancelled})

      assert Preorders.stats() == %{open: 2, received: 1, cancelled: 2}
    end

    test "upcoming_by_month/0 gruppiert offene Platten nach Monat" do
      preorder_fixture(%{artist: "B", release_date: ~D[2026-12-05]})
      preorder_fixture(%{artist: "A", release_date: ~D[2026-11-20]})
      preorder_fixture(%{artist: "C", release_date: ~D[2026-12-01]})
      preorder_fixture(%{release_date: ~D[2026-11-01], status: :received})
      preorder_fixture(%{release_date: nil})

      assert [
               {~D[2026-11-01], [%{artist: "A"}]},
               {~D[2026-12-01], [%{artist: "C"}, %{artist: "B"}]}
             ] =
               Preorders.upcoming_by_month()
    end
  end
end
