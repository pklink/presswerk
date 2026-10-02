defmodule PresswerkWeb.Router do
  use PresswerkWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug PresswerkWeb.Locale
    plug :fetch_live_flash
    plug :put_root_layout, html: {PresswerkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PresswerkWeb do
    pipe_through :browser

    post "/locale", LocaleController, :update

    live_session :localized, on_mount: [PresswerkWeb.Locale] do
      live "/", DashboardLive
      live "/preorders", PreorderLive.Index
      live "/preorders/new", PreorderLive.Form, :new
      live "/preorders/:id", PreorderLive.Show
      live "/preorders/:id/edit", PreorderLive.Form, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PresswerkWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:presswerk, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PresswerkWeb.Telemetry
    end
  end
end
