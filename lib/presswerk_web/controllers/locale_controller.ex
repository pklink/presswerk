defmodule PresswerkWeb.LocaleController do
  use PresswerkWeb, :controller

  def update(conn, params) do
    path = params["return_to"] || "/"
    uri = URI.parse(path)

    path =
      if String.starts_with?(path, "/") and not String.starts_with?(path, "//") and
           not String.contains?(path, ["\\", "\r", "\n"]) and is_nil(uri.host) and
           is_nil(uri.scheme),
         do: path,
         else: "/"

    conn
    |> put_session(:locale, PresswerkWeb.Locale.normalize(params["locale"]))
    |> redirect(to: path)
  end
end
