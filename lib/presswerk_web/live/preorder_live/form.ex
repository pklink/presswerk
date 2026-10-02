defmodule PresswerkWeb.PreorderLive.Form do
  use PresswerkWeb, :live_view

  import PresswerkWeb.PreorderComponents

  alias Presswerk.Preorders
  alias Presswerk.Preorders.Preorder

  @impl true
  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    preorder = %Preorder{ordered_at: Date.utc_today()}

    socket
    |> assign(page_title: "Neue Vorbestellung", preorder: preorder)
    |> assign(:form, to_form(Preorders.change_preorder(preorder)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    preorder = Preorders.get_preorder!(id)

    socket
    |> assign(page_title: "Bearbeiten", preorder: preorder)
    |> assign(:form, to_form(Preorders.change_preorder(preorder)))
  end

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
         |> put_flash(:info, "Vorbestellung gespeichert.")
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
         |> put_flash(:info, "Änderungen gespeichert.")
         |> push_navigate(to: ~p"/preorders/#{preorder}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active={if @live_action == :new, do: :new, else: :preorders}>
      <h1 class="text-2xl font-bold">{@page_title}</h1>

      <.form for={@form} id="preorder-form" phx-change="validate" phx-submit="save" class="max-w-2xl">
        <div class="grid gap-x-4 sm:grid-cols-2">
          <.input field={@form[:artist]} type="text" label="Artist *" autofocus />
          <.input field={@form[:album]} type="text" label="Album *" />
          <.input field={@form[:shop]} type="text" label="Shop" />
          <.input field={@form[:status]} type="select" label="Status" options={status_options()} />
          <.input field={@form[:ordered_at]} type="date" label="Bestellt am" />
          <.input field={@form[:release_date]} type="date" label="Release-Datum" />
        </div>
        <.input field={@form[:cover_url]} type="url" label="Cover-URL" />
        <.input field={@form[:external_url]} type="url" label="Link (z. B. Shop-Seite)" />
        <.input field={@form[:notes]} type="textarea" label="Notizen" rows="3" />

        <div class="flex gap-2 mt-2">
          <button type="submit" class="btn btn-primary" phx-disable-with="Speichere …">Speichern</button>
          <.link
            navigate={if @preorder.id, do: ~p"/preorders/#{@preorder}", else: ~p"/preorders"}
            class="btn btn-ghost"
          >
            Abbrechen
          </.link>
        </div>
      </.form>
    </Layouts.app>
    """
  end
end
