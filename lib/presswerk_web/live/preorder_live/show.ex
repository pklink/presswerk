defmodule PresswerkWeb.PreorderLive.Show do
  @moduledoc "Shows a single preorder with all details."
  use PresswerkWeb, :live_view

  import PresswerkWeb.PreorderComponents

  alias Presswerk.Preorders
  alias Presswerk.Preorders.Preorder

  @doc "Mounts the show page and loads the preorder by ID."
  @impl true
  def mount(%{"id" => id}, _session, socket) do
    preorder = Preorders.get_preorder!(id)

    title =
      if is_nil(preorder.artist),
        do: preorder.album,
        else: "#{preorder.artist} – #{preorder.album}"

    {:ok, assign(socket, page_title: title, preorder: preorder)}
  end

  @doc "Handles quick status updates and deletion."
  @impl true
  def handle_event("update_status", %{"status" => status}, socket) do
    case Preorders.quick_update_status(socket.assigns.preorder, status) do
      {:ok, preorder} ->
        {:noreply,
         socket
         |> assign(:preorder, preorder)
         |> put_flash(:info, gettext("Status updated."))}

      {:error, _reason} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           gettext("Could not update status. Please reload and try again.")
         )}
    end
  end

  def handle_event("delete", _params, socket) do
    {:ok, _} = Preorders.delete_preorder(socket.assigns.preorder)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Preorder deleted."))
     |> push_navigate(to: ~p"/preorders")}
  end

  @doc "Renders the preorder detail page."
  @impl true
  def render(assigns) do
    assigns = assign(assigns, :has_cover, assigns.preorder.cover_url not in [nil, ""])

    ~H"""
    <Layouts.app flash={@flash} active={:preorders} locale={@locale} current_path={@current_path}>
      <.link navigate={~p"/preorders"} class="text-sm text-base-content/70 hover:text-primary">
        <.icon name="hero-arrow-left-micro" class="size-4" /> {gettext("Back to overview")}
      </.link>

      <div class="grid gap-6 sm:grid-cols-[12rem_minmax(0,1fr)]">
        <div class="w-40 sm:w-full">
          <img
            :if={@has_cover}
            id="preorder-cover"
            src={@preorder.cover_url}
            alt={gettext("Cover of %{album}", album: @preorder.album)}
            class="w-full aspect-square object-cover rounded-box border border-base-300"
          />
          <div
            :if={!@has_cover}
            id="preorder-cover-placeholder"
            class="w-full aspect-square rounded-box border border-base-300 bg-base-200 p-4"
            aria-hidden="true"
          >
            <div class="vinyl size-full rounded-full opacity-80"></div>
          </div>
        </div>

        <div class="space-y-4 min-w-0">
          <div>
            <p :if={@preorder.artist} class="text-base-content/70 wrap-anywhere">
              {@preorder.artist}
            </p>

            <h1 class="text-3xl font-bold wrap-anywhere">{@preorder.album}</h1>

            <div id="preorder-status" class="mt-2"><.status_badge status={@preorder.status} /></div>
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

            <dt class="text-base-content/60">{gettext("Price")}</dt>

            <dd>{format_price(@preorder.price)}</dd>
          </dl>

          <div :if={@preorder.notes}>
            <h2 class="text-sm text-base-content/60 mb-1">{gettext("Notes")}</h2>

            <p class="whitespace-pre-line wrap-anywhere">{@preorder.notes}</p>
          </div>

          <div
            :if={Preorder.quick_status_targets(@preorder.status) != []}
            id="preorder-status-actions"
            class={["flex flex-col gap-2 pt-2 sm:flex-row sm:flex-wrap"]}
          >
            <button
              :if={:shipped in Preorder.quick_status_targets(@preorder.status)}
              id="mark-as-shipped"
              type="button"
              phx-click="update_status"
              phx-value-status="shipped"
              phx-disable-with={gettext("Saving …")}
              class={["btn btn-outline btn-sm w-full sm:w-auto"]}
            >
              <.icon name="hero-truck-micro" class="size-4" /> {gettext("Mark as shipped")}
            </button>

            <button
              :if={:received in Preorder.quick_status_targets(@preorder.status)}
              id="mark-as-received"
              type="button"
              phx-click="update_status"
              phx-value-status="received"
              phx-disable-with={gettext("Saving …")}
              class={["btn btn-outline btn-sm w-full sm:w-auto"]}
            >
              <.icon name="hero-check-micro" class="size-4" /> {gettext("Mark as received")}
            </button>
          </div>

          <div
            id="preorder-record-actions"
            class={["flex flex-col gap-2 sm:flex-row sm:flex-wrap"]}
          >
            <.link
              navigate={~p"/preorders/#{@preorder}/edit"}
              class={["btn btn-outline btn-sm w-full sm:w-auto"]}
            >
              <.icon name="hero-pencil-square-micro" class="size-4" /> {gettext("Edit")}
            </.link>

            <button
              id="delete-preorder"
              phx-click="delete"
              data-confirm={gettext("Really delete this preorder?")}
              class={["btn btn-outline btn-error btn-sm w-full sm:w-auto"]}
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
