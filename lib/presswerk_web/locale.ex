defmodule PresswerkWeb.Locale do
  @moduledoc """
  Plug and LiveView hook for setting the locale based on the session.
  """
  import Plug.Conn, only: [get_session: 2]
  import Phoenix.Component, only: [assign: 3]

  @doc "Plug callback: returns the given options unchanged."
  def init(opts), do: opts

  @doc """
  Plug callback: reads the locale from the session and sets it for Gettext.
  """
  def call(conn, _opts) do
    locale = normalize(get_session(conn, :locale))
    Gettext.put_locale(PresswerkWeb.Gettext, locale)
    Plug.Conn.assign(conn, :locale, locale)
  end

  @doc """
  LiveView on_mount hook: sets the locale from the session and assigns it.
  """
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

  @doc """
  Normalizes a locale string to a supported locale (`"en"` or `"de"`).

  Falls back to `"en"` for unsupported or nil values.
  """
  def normalize(locale) when locale in ~w(en de), do: locale
  def normalize(_locale), do: "en"
end
