defmodule PresswerkWeb.Locale do
  import Plug.Conn, only: [get_session: 2]
  import Phoenix.Component, only: [assign: 3]

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = normalize(get_session(conn, :locale))
    Gettext.put_locale(PresswerkWeb.Gettext, locale)
    Plug.Conn.assign(conn, :locale, locale)
  end

  def on_mount(:default, _params, session, socket) do
    locale = normalize(session["locale"])
    Gettext.put_locale(PresswerkWeb.Gettext, locale)

    socket =
      socket
      |> assign(:locale, locale)
      |> Phoenix.LiveView.attach_hook(:locale_path, :handle_params, fn _params, uri, socket ->
        uri = URI.parse(uri)
        path = uri.path <> if(uri.query, do: "?" <> uri.query, else: "")
        {:cont, assign(socket, :current_path, path)}
      end)

    {:cont, socket}
  end

  def normalize(locale) when locale in ~w(en de), do: locale
  def normalize(_locale), do: "en"
end
