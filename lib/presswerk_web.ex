defmodule PresswerkWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use PresswerkWeb, :controller
      use PresswerkWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  @doc "List of static paths served by the endpoint."
  def static_paths, do: ~w(assets fonts images robots.txt)

  @doc "Defines the router macro for Phoenix routers."
  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  @doc "Defines the channel macro for Phoenix channels."
  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @doc "Defines the controller macro for Phoenix controllers."
  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  @doc "Defines the live_view macro for Phoenix LiveViews."
  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  @doc "Defines the live_component macro for Phoenix LiveComponents."
  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  @doc "Defines the html macro for Phoenix components."
  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  @doc false
  defp html_helpers do
    quote do
      use Gettext, backend: PresswerkWeb.Gettext
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      import PresswerkWeb.CoreComponents

      # Common modules used in templates
      alias Phoenix.LiveView.JS
      alias PresswerkWeb.Layouts

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  @doc "Defines verified routes for compile-time route checking."
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: PresswerkWeb.Endpoint,
        router: PresswerkWeb.Router,
        statics: PresswerkWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
