defmodule PresswerkWeb.PreorderComponents do
  @moduledoc """
  Helper components for displaying preorders.
  """
  use Phoenix.Component
  use Gettext, backend: PresswerkWeb.Gettext

  @doc "Returns the localized label for a preorder status."
  def status_label(:preordered), do: gettext("Preordered")
  def status_label(:shipped), do: gettext("Shipped")
  def status_label(:received), do: gettext("Received")
  def status_label(:cancelled), do: gettext("Cancelled")

  @doc "Returns status options as `{label, value}` pairs for select inputs."
  def status_options do
    for s <- Presswerk.Preorders.Preorder.statuses(), do: {status_label(s), s}
  end

  @doc ~S|Formats a date for display, or returns "–" for nil.|
  def format_date(nil), do: "–"

  def format_date(%Date{} = date) do
    format = if Gettext.get_locale(PresswerkWeb.Gettext) == "de", do: "%d.%m.%Y", else: "%Y-%m-%d"
    Calendar.strftime(date, format)
  end

  @doc ~S|Formats a price for display, or returns "–" for nil.|
  def format_price(nil), do: "–"

  def format_price(%Decimal{} = price) do
    price |> Decimal.round(2) |> Decimal.to_string(:normal) |> localize_decimal()
  end

  def format_price(price) when is_number(price),
    do: price |> Decimal.from_float() |> format_price()

  defp localize_decimal(str) do
    if Gettext.get_locale(PresswerkWeb.Gettext) == "de",
      do: String.replace(str, ".", ","),
      else: str
  end

  @doc "Formats a date as a localized month and year (e.g. \"October 2026\")."
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

  @doc """
  Renders a status badge with color coding based on the preorder status.
  """
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
