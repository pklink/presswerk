defmodule PresswerkWeb.PreorderLive.Index do
  use PresswerkWeb, :live_view

  import PresswerkWeb.PreorderComponents

  alias Presswerk.Preorders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Vorbestellungen")}
  end

  # Suche, Filter und Sortierung liegen in der URL (teilbar, Zurück-Button geht).
  @impl true
  def handle_params(params, _uri, socket) do
    search = params["q"] || ""
    status = valid_status(params["status"])
    sort = if params["sort"] == "artist", do: :artist, else: :release_date

    {:noreply,
     socket
     |> assign(search: search, status: status, sort: sort)
     |> assign(:preorders, Preorders.list_preorders(search: search, status: status, sort: sort))}
  end

  defp valid_status(status) do
    if status in Enum.map(Presswerk.Preorders.Preorder.statuses(), &Atom.to_string/1),
      do: status,
      else: ""
  end

  @impl true
  def handle_event("filter", %{"q" => q, "status" => status, "sort" => sort}, socket) do
    {:noreply,
     push_patch(socket, to: ~p"/preorders?#{query_params(q, status, sort)}", replace: true)}
  end

  defp query_params(q, status, sort) do
    [q: q, status: status, sort: sort]
    |> Enum.reject(fn {k, v} -> v in ["", nil] or (k == :sort and v == "release_date") end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:preorders}>
      <div class="flex items-center justify-between gap-3">
        <h1 class="text-2xl font-bold">Vorbestellungen</h1>
        <.link navigate={~p"/preorders/new"} class="btn btn-primary btn-sm">
          <.icon name="hero-plus-micro" class="size-4" /> Neu
        </.link>
      </div>

      <form
        id="filter-form"
        phx-change="filter"
        phx-submit="filter"
        class="grid grid-cols-1 sm:grid-cols-[1fr_auto_auto] gap-3"
      >
        <input
          type="search"
          name="q"
          value={@search}
          placeholder="Artist oder Album suchen …"
          phx-debounce="200"
          autocomplete="off"
          class="input input-bordered w-full"
          aria-label="Suche"
        />
        <select name="status" class="select select-bordered" aria-label="Status">
          <option value="" selected={@status == ""}>Alle Status</option>
          <option
            :for={{label, value} <- status_options()}
            value={value}
            selected={to_string(value) == @status}
          >
            {label}
          </option>
        </select>
        <select name="sort" class="select select-bordered" aria-label="Sortierung">
          <option value="release_date" selected={@sort == :release_date}>Nach Release-Datum</option>
          <option value="artist" selected={@sort == :artist}>Nach Artist</option>
        </select>
      </form>

      <div
        :if={@preorders == []}
        id="preorders-empty"
        class="rounded-box border border-dashed border-base-300 p-8 text-center text-base-content/70"
      >
        Keine Vorbestellungen gefunden.
      </div>

      <div :if={@preorders != []} class="overflow-x-auto rounded-box border border-base-300">
        <table id="preorders" class="table">
          <thead>
            <tr>
              <th>Artist</th>
              <th>Album</th>
              <th class="hidden sm:table-cell">Shop</th>
              <th>Release</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr
              :for={p <- @preorders}
              id={"preorder-#{p.id}"}
              class="hover:bg-base-200 cursor-pointer"
              phx-click={JS.navigate(~p"/preorders/#{p}")}
            >
              <td class="font-medium">
                <.link navigate={~p"/preorders/#{p}"} class="hover:text-primary">{p.artist}</.link>
              </td>
              <td>{p.album}</td>
              <td class="hidden sm:table-cell text-base-content/70">{p.shop}</td>
              <td class="whitespace-nowrap tabular-nums">{format_date(p.release_date)}</td>
              <td><.status_badge status={p.status} /></td>
            </tr>
          </tbody>
        </table>
      </div>
    </Layouts.app>
    """
  end
end
