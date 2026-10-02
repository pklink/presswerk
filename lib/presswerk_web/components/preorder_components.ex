defmodule PresswerkWeb.PreorderComponents do
  @moduledoc """
  Kleine Hilfen zur Darstellung von Vorbestellungen.
  """
  use Phoenix.Component
  use Gettext, backend: PresswerkWeb.Gettext

  def status_label(:preordered), do: gettext("Preordered")
  def status_label(:shipped), do: gettext("Shipped")
  def status_label(:received), do: gettext("Received")
  def status_label(:cancelled), do: gettext("Cancelled")

  def status_options do
    for s <- Presswerk.Preorders.Preorder.statuses(), do: {status_label(s), s}
  end

  def format_date(nil), do: "–"

  def format_date(%Date{} = date) do
    format = if Gettext.get_locale(PresswerkWeb.Gettext) == "de", do: "%d.%m.%Y", else: "%Y-%m-%d"
    Calendar.strftime(date, format)
  end

  def format_month(%Date{} = date) do
    months = [
      gettext("January"),
      gettext("February"),
      gettext("March"),
      gettext("April"),
      gettext("May"),
      gettext("June"),
      gettext("July"),
      gettext("August"),
      gettext("September"),
      gettext("October"),
      gettext("November"),
      gettext("December")
    ]

    "#{Enum.at(months, date.month - 1)} #{date.year}"
  end

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
