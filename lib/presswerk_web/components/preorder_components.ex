defmodule PresswerkWeb.PreorderComponents do
  @moduledoc """
  Kleine Hilfen zur Darstellung von Vorbestellungen.
  """
  use Phoenix.Component

  @months ~w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)

  def status_label(:preordered), do: "Vorbestellt"
  def status_label(:shipped), do: "Versendet"
  def status_label(:received), do: "Erhalten"
  def status_label(:cancelled), do: "Storniert"

  def status_options do
    for s <- Presswerk.Preorders.Preorder.statuses(), do: {status_label(s), s}
  end

  def format_date(nil), do: "–"
  def format_date(%Date{} = d), do: Calendar.strftime(d, "%d.%m.%Y")

  def format_month(%Date{year: y, month: m}), do: "#{Enum.at(@months, m - 1)} #{y}"

  attr :status, :atom, required: true

  def status_badge(assigns) do
    ~H"""
    <span class={[
      "badge badge-sm whitespace-nowrap",
      @status == :preordered && "badge-warning",
      @status == :shipped && "badge-info",
      @status == :received && "badge-success",
      @status == :cancelled && "badge-ghost line-through"
    ]}>
      {status_label(@status)}
    </span>
    """
  end
end
