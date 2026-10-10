defmodule PresswerkWeb.Gettext do
  @moduledoc "Gettext backend for translations in the Presswerk web application."
  use Gettext.Backend, otp_app: :presswerk
end
