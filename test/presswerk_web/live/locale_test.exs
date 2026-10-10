defmodule PresswerkWeb.LocaleTest do
  use PresswerkWeb.ConnCase

  import Phoenix.LiveViewTest
  import Presswerk.PreordersFixtures

  test "English is the default for HTTP and LiveView", %{conn: conn} do
    preorder_fixture(%{release_date: ~D[2026-03-20]})
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ ~s(lang="en")

    {:ok, view, html} = live(conn)
    assert html =~ "Open preorders"
    assert html =~ "March 2026"
    assert html =~ "2026-03-20"
    assert has_element?(view, "#app-footer #locale-select option[value=en][selected]")
  end

  test "language selection persists through navigation and preserves filters", %{conn: conn} do
    preorder_fixture(%{artist: "Test artist", release_date: ~D[2026-03-20]})
    path = ~p"/preorders?q=Test&status=preordered&sort=artist"
    {:ok, view, _} = live(conn, path)
    assert has_element?(view, ~s(#locale-form input[name=return_to][value="#{path}"]))

    conn = post(conn, ~p"/locale", %{locale: "de", return_to: path})
    assert redirected_to(conn) == path
    assert get_session(conn, :locale) == "de"

    conn = conn |> recycle() |> get(path)
    assert html_response(conn, 200) =~ ~s(lang="de")
    {:ok, view, html} = live(conn)
    assert html =~ "Vorbestellungen"
    assert html =~ "Vorbestellt"
    assert html =~ "20.03.2026"
    assert has_element?(view, "#app-footer #locale-select option[value=de][selected]")

    {:ok, dashboard, html} =
      view |> element("nav a[href='/']") |> render_click() |> follow_redirect(conn)

    assert html =~ "März 2026"
    assert has_element?(dashboard, "#stat-open", "Offene Vorbestellungen")

    conn = conn |> recycle() |> post(~p"/locale", %{locale: "en", return_to: "/"})
    {:ok, _, html} = live(recycle(conn), ~p"/")
    assert html =~ "Open preorders"
  end

  test "German forms translate validation, duplicates and saved messages", %{conn: conn} do
    p = preorder_fixture()
    conn = init_test_session(conn, %{locale: "de"})
    {:ok, view, _} = live(conn, ~p"/preorders/new")

    html = view |> form("#preorder-form", preorder: %{artist: ""}) |> render_change()
    assert html =~ "darf nicht leer sein"

    html =
      view
      |> form("#preorder-form", preorder: %{artist: p.artist, album: p.album})
      |> render_submit()

    assert html =~ "Diese Platte wurde bereits erfasst."

    {:ok, _, html} =
      view
      |> form("#preorder-form", preorder: %{artist: "Neuer Artist", album: "Neues Album"})
      |> render_submit()
      |> follow_redirect(conn)

    assert html =~ "Vorbestellung gespeichert."
  end

  test "configured default locale is used when no session locale is set", %{conn: conn} do
    original = Application.get_env(:presswerk, :default_locale)
    Application.put_env(:presswerk, :default_locale, "de")

    try do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ ~s(lang="de")

      {:ok, _view, html} = live(conn)
      assert html =~ "Vorbestellungen"
    after
      restore_default_locale(original)
    end
  end

  test "invalid configured default locale falls back to English", %{conn: conn} do
    original = Application.get_env(:presswerk, :default_locale)
    Application.put_env(:presswerk, :default_locale, "fr")

    try do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ ~s(lang="en")
    after
      restore_default_locale(original)
    end
  end

  test "unsupported locales fall back to English and redirects stay local", %{conn: conn} do
    conn = init_test_session(conn, %{locale: "fr"})
    {:ok, _, html} = live(conn, ~p"/")
    assert html =~ "Open preorders"

    for path <- ["https://example.org", "//example.org", "/\\example.org"] do
      response = post(conn, ~p"/locale", %{locale: "fr", return_to: path})
      assert get_session(response, :locale) == "en"
      assert redirected_to(response) == "/"
    end
  end

  defp restore_default_locale(nil), do: Application.delete_env(:presswerk, :default_locale)
  defp restore_default_locale(value), do: Application.put_env(:presswerk, :default_locale, value)
end
