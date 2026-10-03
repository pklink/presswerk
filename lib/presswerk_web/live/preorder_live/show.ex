defmodule PresswerkWeb.PreorderLive.Show do
  use PresswerkWeb, :live_view

  import PresswerkWeb.PreorderComponents

  alias Presswerk.Preorders

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    preorder = Preorders.get_preorder!(id)

    {:ok,
     assign(socket, page_title: "#{preorder.artist} – #{preorder.album}", preorder: preorder)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Preorders.delete_preorder(socket.assigns.preorder)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Preorder deleted."))
     |> push_navigate(to: ~p"/preorders")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:preorders} locale={@locale} current_path={@current_path}>
      <.link navigate={~p"/preorders"} class="text-sm text-base-content/70 hover:text-primary">
        <.icon name="hero-arrow-left-micro" class="size-4" /> {gettext("Back to overview")}
      </.link>

      <div class="grid gap-6 sm:grid-cols-[12rem_minmax(0,1fr)]">
        <div class="w-40 sm:w-full">
          <img
            :if={@preorder.cover_url}
            src={@preorder.cover_url}
            alt={gettext("Cover of %{album}", album: @preorder.album)}
            class="w-full aspect-square object-cover rounded-box border border-base-300"
          />
          <div
            :if={!@preorder.cover_url}
            class="vinyl w-full aspect-square rounded-full opacity-80"
            aria-hidden="true"
          >
          </div>
        </div>

        <div class="space-y-4 min-w-0">
          <div>
            <p class="text-base-content/70 wrap-anywhere">{@preorder.artist}</p>
            <h1 class="text-3xl font-bold wrap-anywhere">{@preorder.album}</h1>
            <div class="mt-2"><.status_badge status={@preorder.status} /></div>
          </div>

          <dl class="grid grid-cols-[auto_minmax(0,1fr)] gap-x-4 gap-y-2 text-sm sm:gap-x-6">
            <dt class="text-base-content/60">{gettext("Shop")}</dt>
            <dd class="wrap-anywhere">{@preorder.shop || "–"}</dd>
            <dt class="text-base-content/60">{gettext("Ordered on")}</dt>
            <dd>{format_date(@preorder.ordered_at)}</dd>
            <dt class="text-base-content/60">{gettext("Release")}</dt>
            <dd>{format_date(@preorder.release_date)}</dd>
            <dt class="text-base-content/60">{gettext("Article URL")}</dt>
            <dd class="break-all">
              <a
                :if={@preorder.article_url}
                href={@preorder.article_url}
                target="_blank"
                rel="noopener noreferrer"
                class="link link-primary"
              >
                {@preorder.article_url}
              </a>
              <span :if={!@preorder.article_url}>–</span>
            </dd>
            <dt class="text-base-content/60">{gettext("Order URL")}</dt>
            <dd class="break-all">
              <a
                :if={@preorder.order_url}
                href={@preorder.order_url}
                target="_blank"
                rel="noopener noreferrer"
                class="link link-primary"
              >
                {@preorder.order_url}
              </a>
              <span :if={!@preorder.order_url}>–</span>
            </dd>
          </dl>

          <div :if={@preorder.notes}>
            <h2 class="text-sm text-base-content/60 mb-1">{gettext("Notes")}</h2>
            <p class="whitespace-pre-line wrap-anywhere">{@preorder.notes}</p>
          </div>

          <div class="flex gap-2 pt-2">
            <.link navigate={~p"/preorders/#{@preorder}/edit"} class="btn btn-primary btn-sm">
              <.icon name="hero-pencil-square-micro" class="size-4" /> {gettext("Edit")}
            </.link>
            <button
              id="delete-preorder"
              phx-click="delete"
              data-confirm={gettext("Really delete this preorder?")}
              class="btn btn-ghost btn-sm text-error"
            >
              <.icon name="hero-trash-micro" class="size-4" /> {gettext("Delete")}
            </button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
