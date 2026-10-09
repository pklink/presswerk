defmodule PresswerkWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use PresswerkWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :active, :atom, default: nil, doc: ":dashboard, :preorders or :new"
  attr :locale, :string, required: true
  attr :current_path, :string, required: true

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-dvh flex flex-col">
      <header class="border-b border-base-300 bg-base-200/60 backdrop-blur sticky top-0 z-10">
        <div class="mx-auto max-w-5xl px-4 sm:px-6 py-3 flex flex-wrap items-center gap-x-6 gap-y-3">
          <.link navigate={~p"/"} class="flex items-center gap-2 group">
            <span class="vinyl size-8 rounded-full" aria-hidden="true"></span>
            <span class="leading-tight">
              <span class="block text-lg font-bold tracking-tight">Presswerk</span>
              <span class="hidden sm:block text-xs text-base-content/60">
                {gettext("Keep track of your vinyl preorders.")}
              </span>
            </span>
          </.link>

          <div class="ml-auto sm:hidden"><.theme_toggle /></div>
          <nav
            class="order-3 grid w-full grid-cols-3 gap-1 text-sm sm:order-none sm:ml-auto sm:flex sm:w-auto sm:items-center"
            aria-label={gettext("Main navigation")}
          >
            <.nav_link navigate={~p"/"} active={@active == :dashboard}>{gettext("Dashboard")}</.nav_link>
            <.nav_link navigate={~p"/preorders"} active={@active == :preorders}>
              <span class="sm:hidden">{gettext("Records")}</span><span class="hidden sm:inline">{gettext(
                "Preorders"
              )}</span>
            </.nav_link>
            <.nav_link navigate={~p"/preorders/new"} active={@active == :new}>
              <.icon name="hero-plus-micro" class="size-4" />
              <span class="sm:hidden">{gettext("New")}</span><span class="hidden sm:inline">{gettext(
                "New preorder"
              )}</span>
            </.nav_link>
            <div class="hidden sm:block sm:ml-2"><.theme_toggle /></div>
          </nav>
        </div>
      </header>

      <main class="flex-1 px-4 py-6 sm:px-6 sm:py-8">
        <div class="mx-auto max-w-5xl space-y-6">
          {render_slot(@inner_block)}
        </div>
      </main>

      <footer id="app-footer" class="border-t border-base-300 px-4 py-4 sm:px-6">
        <div class="mx-auto max-w-5xl flex items-center justify-between gap-4">
          <p class="text-xs text-base-content/60">
            <a
              href="https://github.com/pklink/presswerk"
              aria-label={gettext("Presswerk on GitHub")}
              class="font-medium text-base-content underline decoration-base-content/30 underline-offset-4 hover:text-primary"
            >Presswerk</a>
            v{to_string(Application.spec(:presswerk, :vsn))}
          </p>
          <.form for={%{}} action={~p"/locale"} id="locale-form" class="flex items-center gap-2">
            <input type="hidden" name="return_to" value={@current_path} />
            <select
              id="locale-select"
              name="locale"
              class="select sm:select-sm"
              aria-label={gettext("Language")}
            >
              {Phoenix.HTML.Form.options_for_select(
                [{"English", "en"}, {"Deutsch", "de"}],
                @locale
              )}
            </select>
            <noscript>
              <button type="submit" class="btn btn-sm">{gettext("Save")}</button>
            </noscript>
          </.form>
        </div>
      </footer>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  attr :navigate, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      aria-current={@active && "page"}
      class={[
        "min-h-11 px-2 sm:px-3 rounded-md flex items-center justify-center gap-1 transition-colors whitespace-nowrap",
        @active && "bg-primary text-primary-content font-medium",
        !@active && "hover:bg-base-300"
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("No connection")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Reconnecting …")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Reconnecting …")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-3 sm:p-2 cursor-pointer w-1/3"
        aria-label={gettext("Use system theme")}
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-3 sm:p-2 cursor-pointer w-1/3"
        aria-label={gettext("Use light theme")}
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-3 sm:p-2 cursor-pointer w-1/3"
        aria-label={gettext("Use dark theme")}
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
