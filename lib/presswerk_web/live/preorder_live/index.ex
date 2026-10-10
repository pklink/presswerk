defmodule PresswerkWeb.PreorderLive.Index do
  @moduledoc "Lists all preorders with search, filter and sort."
  use PresswerkWeb, :live_view

  import PresswerkWeb.PreorderComponents

  alias Presswerk.Preorders

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, gettext("Preorders"))}
  end

  # Search, filter and sorting live in the URL (shareable, back button works).
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

  @doc false
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

  @doc false
  defp query_params(q, status, sort) do
    [q: q, status: status, sort: sort]
    |> Enum.reject(fn {k, v} -> v in ["", nil] or (k == :sort and v == "release_date") end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:preorders} locale={@locale} current_path={@current_path}>
      <div class="flex items-center justify-between gap-3">
        <h1 class="text-2xl font-bold">{gettext("Preorders")}</h1>
        <.link navigate={~p"/preorders/new"} class="btn btn-primary btn-sm">
          <.icon name="hero-plus-micro" class="size-4" /> {gettext("New")}
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
          placeholder={gettext("Search artist or album …")}
          phx-debounce="200"
          autocomplete="off"
          class="input input-bordered w-full"
          aria-label={gettext("Search")}
        />
        <select name="status" class="select select-bordered w-full" aria-label={gettext("Status")}>
          <option value="" selected={@status == ""}>{gettext("All statuses")}</option>
          <option
            :for={{label, value} <- status_options()}
            value={value}
            selected={to_string(value) == @status}
          >
            {label}
          </option>
        </select>
        <select name="sort" class="select select-bordered w-full" aria-label={gettext("Sort order")}>
          <option value="release_date" selected={@sort == :release_date}>
            {gettext("By release date")}
          </option>
          <option value="artist" selected={@sort == :artist}>{gettext("By artist")}</option>
        </select>
      </form>

      <div
        :if={@preorders == []}
        id="preorders-empty"
        class="rounded-box border border-dashed border-base-300 p-8 text-center text-base-content/70"
      >
        {gettext("No preorders found.")}
      </div>

      <div :if={@preorders != []} class="rounded-box border border-base-300">
        <table id="preorders" class="table block w-full sm:table">
          <thead>
            <tr>
              <th class="hidden sm:table-cell">{gettext("Artist")}</th>
              <th class="hidden sm:table-cell">{gettext("Album")}</th>
              <th class="hidden sm:table-cell">{gettext("Shop")}</th>
              <th class="hidden sm:table-cell">{gettext("Release")}</th>
              <th class="hidden sm:table-cell">{gettext("Status")}</th>
            </tr>
          </thead>
          <tbody class="block sm:table-row-group">
            <tr
              :for={p <- @preorders}
              id={"preorder-#{p.id}"}
              class="grid grid-cols-[minmax(0,1fr)_auto] gap-x-3 gap-y-1 border-b border-base-300 p-4 last:border-b-0 sm:table-row sm:border-0 sm:p-0 hover:bg-base-200 cursor-pointer"
              phx-click={JS.navigate(~p"/preorders/#{p}")}
            >
              <td class={[
                "order-1 min-w-0 p-0 font-medium sm:table-cell sm:p-3",
                is_nil(p.artist) && "hidden sm:table-cell"
              ]}>
                {p.artist}
              </td>
              <td class={[
                "col-span-2 min-w-0 p-0 wrap-anywhere sm:table-cell sm:p-3",
                if(is_nil(p.artist), do: "order-1 font-medium", else: "order-3")
              ]}>
                <.link navigate={~p"/preorders/#{p}"} class="hover:text-primary">{p.album}</.link>
              </td>
              <td class="hidden sm:table-cell text-base-content/70 wrap-anywhere">{p.shop}</td>
              <td class="order-4 col-span-2 p-0 text-sm text-base-content/70 tabular-nums sm:table-cell sm:p-3 sm:text-base sm:text-base-content">
                <span class="sm:hidden">{gettext("Release")}: </span>{format_date(p.release_date)}
              </td>
              <td class="order-2 p-0 sm:table-cell sm:p-3"><.status_badge status={p.status} /></td>
            </tr>
          </tbody>
        </table>
      </div>
    </Layouts.app>
    """
  end
end
