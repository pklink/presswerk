defmodule PresswerkWeb.PreorderLiveTest do
  use PresswerkWeb.ConnCase

  import Phoenix.LiveViewTest
  import Presswerk.PreordersFixtures

  alias Presswerk.Preorders

  describe "Dashboard" do
    test "zeigt Kennzahlen und Releases nach Monat", %{conn: conn} do
      preorder_fixture(%{artist: "Artist A", album: "Album X", release_date: ~D[2026-11-20]})
      preorder_fixture(%{status: :received})

      {:ok, view, html} = live(conn, ~p"/")
      assert html =~ "Keep track of your vinyl preorders."
      assert has_element?(view, "#stat-open", "1")
      assert has_element?(view, "#stat-received", "1")
      assert has_element?(view, "#month-2026-11", "Artist A")
      assert render(view) =~ "November 2026"
    end
  end

  describe "Index" do
    setup do
      %{
        a: preorder_fixture(%{artist: "Zebra", album: "Stripes", release_date: ~D[2026-12-01]}),
        b: preorder_fixture(%{artist: "Alpha", album: "Wolf", status: :received})
      }
    end

    test "listet Vorbestellungen", %{conn: conn, a: a, b: b} do
      {:ok, view, _} = live(conn, ~p"/preorders")
      assert has_element?(view, "#preorder-#{a.id}")
      assert has_element?(view, "#preorder-#{b.id}")
    end

    test "Suche filtert", %{conn: conn, a: a, b: b} do
      {:ok, view, _} = live(conn, ~p"/preorders")

      view |> form("#filter-form", %{q: "zeb"}) |> render_change()

      assert has_element?(view, "#preorder-#{a.id}")
      refute has_element?(view, "#preorder-#{b.id}")
      assert_patch(view, ~p"/preorders?q=zeb")
    end

    test "Statusfilter filtert", %{conn: conn, a: a, b: b} do
      {:ok, view, _} = live(conn, ~p"/preorders")

      view |> form("#filter-form", %{status: "received"}) |> render_change()

      refute has_element?(view, "#preorder-#{a.id}")
      assert has_element?(view, "#preorder-#{b.id}")
    end

    test "Sortierung nach Artist", %{conn: conn, a: a, b: b} do
      {:ok, view, _} = live(conn, ~p"/preorders?sort=artist")
      html = render(view)
      assert :binary.match(html, "preorder-#{b.id}") < :binary.match(html, "preorder-#{a.id}")
    end

    test "leere Suche zeigt Hinweis", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/preorders?q=gibtsnicht")
      assert has_element?(view, "#preorders-empty")
    end
  end

  describe "Neu" do
    test "schlägt vorhandene Artists und Shops vor und erlaubt neue Werte", %{conn: conn} do
      preorder_fixture(%{artist: "Boygenius", shop: "Bandcamp"})
      preorder_fixture(%{artist: "Boygenius", shop: "Bandcamp"})
      preorder_fixture(%{artist: "", shop: ""})

      {:ok, view, _} = live(conn, ~p"/preorders/new")

      assert has_element?(view, ~s(#preorder_artist[list="artist-suggestions"]))
      assert has_element?(view, ~s(#preorder_shop[list="shop-suggestions"]))
      assert has_element?(view, ~s(#artist-suggestions option[value="Boygenius"]))
      assert has_element?(view, ~s(#shop-suggestions option[value="Bandcamp"]))
      refute has_element?(view, ~s(#artist-suggestions option[value=""]))
      refute has_element?(view, "#artist-suggestions option:nth-child(2)")
      refute has_element?(view, "#shop-suggestions option:nth-child(2)")

      {:ok, _, _} =
        view
        |> form("#preorder-form",
          preorder: %{artist: "New Artist", album: "New Album", shop: "New Shop"}
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert [%{shop: "New Shop"}] = Preorders.list_preorders(search: "New Artist")
    end

    test "legt Vorbestellung an", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/preorders/new")

      {:ok, _show, html} =
        view
        |> form("#preorder-form",
          preorder: %{artist: "Phoebe Bridgers", album: "Punisher", status: "shipped"}
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Preorder saved."
      assert html =~ "Punisher"
      assert [%{artist: "Phoebe Bridgers", status: :shipped}] = Preorders.list_preorders()
    end

    test "legt Vorbestellung ohne Artist an und zeigt sie an", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/preorders/new")

      {:ok, _show, html} =
        view
        |> form("#preorder-form",
          preorder: %{artist: "", album: "Ohne Interpret", release_date: "2026-11-20"}
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Ohne Interpret"
      assert [%{artist: nil} = p] = Preorders.list_preorders()

      {:ok, index, _} = live(conn, ~p"/preorders")
      assert has_element?(index, "#preorder-#{p.id} a", "Ohne Interpret")
      {:ok, dashboard, _} = live(conn, ~p"/")
      assert render(dashboard) =~ "Ohne Interpret"
    end

    test "speichert und zeigt Artikel- und Bestell-URL", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/preorders/new")
      article_url = "https://example.com/article"
      order_url = "https://example.com/orders/123"

      {:ok, _show, html} =
        view
        |> form("#preorder-form",
          preorder: %{
            artist: "Artist",
            album: "Album",
            article_url: article_url,
            order_url: order_url
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ ~s(href="#{article_url}")
      assert html =~ ~s(href="#{order_url}")
      assert [%{article_url: ^article_url, order_url: ^order_url}] = Preorders.list_preorders()
    end

    test "speichert und zeigt Preis", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/preorders/new")

      {:ok, _show, html} =
        view
        |> form("#preorder-form",
          preorder: %{
            artist: "Artist",
            album: "Album",
            price: "24.99"
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "24.99"
      assert [%{price: %Decimal{}} = p] = Preorders.list_preorders()
      assert p.price == Decimal.from_float(24.99)
    end

    test "validiert Pflichtfelder", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/preorders/new")

      html = view |> form("#preorder-form", preorder: %{artist: ""}) |> render_change()
      assert html =~ "can&#39;t be blank"
    end

    test "zeigt Dublettenmeldung", %{conn: conn} do
      p = preorder_fixture()
      {:ok, view, _} = live(conn, ~p"/preorders/new")

      html =
        view
        |> form("#preorder-form", preorder: %{artist: p.artist, album: p.album})
        |> render_submit()

      assert html =~ "This record has already been added."
    end
  end

  describe "Show / Edit / Delete" do
    test "zeigt Vorschläge auch beim Bearbeiten", %{conn: conn} do
      p = preorder_fixture(%{artist: "Boygenius", shop: "Bandcamp"})
      {:ok, view, _} = live(conn, ~p"/preorders/#{p}/edit")

      assert has_element?(view, ~s(#artist-suggestions option[value="Boygenius"]))
      assert has_element?(view, ~s(#shop-suggestions option[value="Bandcamp"]))
    end

    test "zeigt Details", %{conn: conn} do
      p = preorder_fixture(%{shop: "Bandcamp", notes: "Klarer Vinyl"})
      {:ok, _view, html} = live(conn, ~p"/preorders/#{p}")
      assert html =~ p.album
      assert html =~ "Bandcamp"
      assert html =~ "Klarer Vinyl"
    end

    test "bearbeitet", %{conn: conn} do
      p = preorder_fixture()
      {:ok, view, _} = live(conn, ~p"/preorders/#{p}/edit")

      {:ok, _, html} =
        view
        |> form("#preorder-form", preorder: %{status: "received", shop: "Neuer Shop"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/preorders/#{p}")

      assert html =~ "Changes saved."
      assert html =~ "Neuer Shop"
      assert Preorders.get_preorder!(p.id).status == :received
    end

    test "löscht", %{conn: conn} do
      p = preorder_fixture()
      {:ok, view, _} = live(conn, ~p"/preorders/#{p}")

      {:ok, _, html} =
        view
        |> element("#delete-preorder")
        |> render_click()
        |> follow_redirect(conn, ~p"/preorders")

      assert html =~ "Preorder deleted."
      assert Preorders.list_preorders() == []
    end
  end
end
