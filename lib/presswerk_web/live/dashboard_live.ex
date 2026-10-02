defmodule PresswerkWeb.DashboardLive do
  use PresswerkWeb, :live_view

  import PresswerkWeb.PreorderComponents

  alias Presswerk.Preorders

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, gettext("Dashboard"))
     |> assign(:stats, Preorders.stats())
     |> assign(:months, Preorders.upcoming_by_month())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:dashboard} locale={@locale} current_path={@current_path}>
      <section class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <.stat label={gettext("Open preorders")} value={@stats.open} id="stat-open" accent />
        <.stat label={gettext("Received records")} value={@stats.received} id="stat-received" />
        <.stat label={gettext("Cancelled preorders")} value={@stats.cancelled} id="stat-cancelled" />
      </section>

      <section>
        <h2 class="text-xl font-bold mb-4">{gettext("Upcoming releases")}</h2>

        <div
          :if={@months == []}
          id="upcoming-empty"
          class="rounded-box border border-dashed border-base-300 p-8 text-center text-base-content/70"
        >
          <p>{gettext("No open preorders with a release date.")}</p>
          <.link navigate={~p"/preorders/new"} class="btn btn-primary btn-sm mt-3">
            {gettext("Add preorder")}
          </.link>
        </div>

        <div id="upcoming" class="space-y-6">
          <div :for={{month, preorders} <- @months} id={"month-#{month.year}-#{month.month}"}>
            <h3 class="text-sm font-semibold uppercase tracking-wide text-primary mb-2">
              {format_month(month)}
            </h3>
            <ul class="divide-y divide-base-300 rounded-box border border-base-300 bg-base-200/40">
              <li :for={p <- preorders}>
                <.link
                  navigate={~p"/preorders/#{p}"}
                  class="flex flex-col items-start gap-2 px-4 py-3 hover:bg-base-200 sm:flex-row sm:items-center sm:justify-between sm:gap-3"
                >
                  <span class="min-w-0 wrap-anywhere">
                    <span class="font-medium">{p.artist}</span>
                    <span class="text-base-content/60"> – </span>
                    <span>{p.album}</span>
                  </span>
                  <span class="flex items-center gap-3 shrink-0 text-sm text-base-content/60">
                    <span>{format_date(p.release_date)}</span>
                    <.status_badge status={p.status} />
                  </span>
                </.link>
              </li>
            </ul>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  attr :label, :string, required: true
  attr :value, :integer, required: true
  attr :id, :string, required: true
  attr :accent, :boolean, default: false

  defp stat(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "rounded-box border p-5",
        @accent && "border-primary/60 bg-primary/10",
        !@accent && "border-base-300 bg-base-200/40"
      ]}
    >
      <div class="text-4xl font-bold tabular-nums">{@value}</div>
      <div class="text-sm text-base-content/70 mt-1">{@label}</div>
    </div>
    """
  end
end
