defmodule PresswerkWeb.PreorderLive.Form do
  @moduledoc "Form for creating and editing preorders."
  use PresswerkWeb, :live_view

  import PresswerkWeb.PreorderComponents

  alias Presswerk.Preorders
  alias Presswerk.Preorders.Preorder

  @doc "Mounts the form and prepares suggestions and the changeset."
  @impl true
  def mount(params, _session, socket) do
    preorders = Preorders.list_preorders()

    {:ok,
     socket
     |> assign(:artist_options, suggestions(preorders, :artist))
     |> assign(:shop_options, suggestions(preorders, :shop))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp suggestions(preorders, field) do
    preorders
    |> Enum.map(&Map.get(&1, field))
    |> Enum.filter(&(is_binary(&1) and String.trim(&1) != ""))
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp apply_action(socket, :new, _params) do
    preorder = %Preorder{ordered_at: Date.utc_today()}

    socket
    |> assign(page_title: gettext("New preorder"), preorder: preorder)
    |> assign(:form, to_form(Preorders.change_preorder(preorder)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    preorder = Preorders.get_preorder!(id)

    socket
    |> assign(page_title: gettext("Edit"), preorder: preorder)
    |> assign(:form, to_form(Preorders.change_preorder(preorder)))
  end

  @doc "Handles form events: validates input on change and saves on submit."
  @impl true
  def handle_event("validate", %{"preorder" => params}, socket) do
    changeset = Preorders.change_preorder(socket.assigns.preorder, params)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"preorder" => params}, socket) do
    save(socket, socket.assigns.live_action, params)
  end

  defp save(socket, :new, params) do
    case Preorders.create_preorder(params) do
      {:ok, preorder} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Preorder saved."))
         |> push_navigate(to: ~p"/preorders/#{preorder}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save(socket, :edit, params) do
    case Preorders.update_preorder(socket.assigns.preorder, params) do
      {:ok, preorder} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Changes saved."))
         |> push_navigate(to: ~p"/preorders/#{preorder}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @doc "Renders the preorder form."
  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      active={if @live_action == :new, do: :new, else: :preorders}
      locale={@locale}
      current_path={@current_path}
    >
      <h1 class="text-2xl font-bold">{@page_title}</h1>

      <.form for={@form} id="preorder-form" phx-change="validate" phx-submit="save" class="max-w-2xl">
        <div class="grid gap-x-4 sm:grid-cols-2">
          <.input
            field={@form[:artist]}
            type="text"
            label={gettext("Artist")}
            list="artist-suggestions"
            autofocus
          />
          <datalist id="artist-suggestions">
            <option :for={artist <- @artist_options} value={artist} />
          </datalist>
          <.input field={@form[:album]} type="text" label={gettext("Album") <> " *"} />
          <.input
            field={@form[:shop]}
            type="text"
            label={gettext("Shop")}
            list="shop-suggestions"
          />
          <datalist id="shop-suggestions">
            <option :for={shop <- @shop_options} value={shop} />
          </datalist>
          <.input
            field={@form[:status]}
            type="select"
            label={gettext("Status")}
            options={status_options()}
          />
          <.input field={@form[:ordered_at]} type="date" label={gettext("Ordered on")} />
          <.input field={@form[:release_date]} type="date" label={gettext("Release date")} />
        </div>
        <.input field={@form[:cover_url]} type="url" label={gettext("Cover URL")} />
        <.input field={@form[:article_url]} type="url" label={gettext("Article URL")} />
        <.input field={@form[:order_url]} type="url" label={gettext("Order URL")} />
        <.input field={@form[:price]} type="number" label={price_label()} step="0.01" />
        <.input field={@form[:notes]} type="textarea" label={gettext("Notes")} rows="3" />

        <div class="flex gap-2 mt-2">
          <button type="submit" class="btn btn-primary" phx-disable-with={gettext("Saving …")}>{gettext(
            "Save"
          )}</button>
          <.link
            navigate={if @preorder.id, do: ~p"/preorders/#{@preorder}", else: ~p"/preorders"}
            class="btn btn-ghost"
          >
            {gettext("Cancel")}
          </.link>
        </div>
      </.form>
    </Layouts.app>
    """
  end
end
