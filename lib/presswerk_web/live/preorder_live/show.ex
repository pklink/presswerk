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
     |> put_flash(:info, "Vorbestellung gelöscht.")
     |> push_navigate(to: ~p"/preorders")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={:preorders}>
      <.link navigate={~p"/preorders"} class="text-sm text-base-content/70 hover:text-primary">
        <.icon name="hero-arrow-left-micro" class="size-4" /> Zurück zur Übersicht
      </.link>

      <div class="grid gap-6 sm:grid-cols-[12rem_1fr]">
        <div>
          <img
            :if={@preorder.cover_url}
            src={@preorder.cover_url}
            alt={"Cover von #{@preorder.album}"}
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
            <p class="text-base-content/70">{@preorder.artist}</p>
            <h1 class="text-3xl font-bold break-words">{@preorder.album}</h1>
            <div class="mt-2"><.status_badge status={@preorder.status} /></div>
          </div>

          <dl class="grid grid-cols-[auto_1fr] gap-x-6 gap-y-2 text-sm">
            <dt class="text-base-content/60">Shop</dt>
            <dd>{@preorder.shop || "–"}</dd>
            <dt class="text-base-content/60">Bestellt am</dt>
            <dd>{format_date(@preorder.ordered_at)}</dd>
            <dt class="text-base-content/60">Release</dt>
            <dd>{format_date(@preorder.release_date)}</dd>
            <dt class="text-base-content/60">Link</dt>
            <dd class="break-all">
              <a
                :if={@preorder.external_url}
                href={@preorder.external_url}
                target="_blank"
                rel="noopener noreferrer"
                class="link link-primary"
              >
                {@preorder.external_url}
              </a>
              <span :if={!@preorder.external_url}>–</span>
            </dd>
          </dl>

          <div :if={@preorder.notes}>
            <h2 class="text-sm text-base-content/60 mb-1">Notizen</h2>
            <p class="whitespace-pre-line">{@preorder.notes}</p>
          </div>

          <div class="flex gap-2 pt-2">
            <.link navigate={~p"/preorders/#{@preorder}/edit"} class="btn btn-primary btn-sm">
              <.icon name="hero-pencil-square-micro" class="size-4" /> Bearbeiten
            </.link>
            <button
              id="delete-preorder"
              phx-click="delete"
              data-confirm="Diese Vorbestellung wirklich löschen?"
              class="btn btn-ghost btn-sm text-error"
            >
              <.icon name="hero-trash-micro" class="size-4" /> Löschen
            </button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
