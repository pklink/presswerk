defmodule Presswerk.Config do
  @moduledoc """
  Loads user configuration from a JSON file at application startup.

  The file path defaults to `config/presswerk.json` and can be overridden
  with the `PRESSWERK_CONFIG` environment variable. A missing file logs a
  warning; defaults are used instead.
  """

  require Logger

  @default_path "config/presswerk.json"

  @doc """
  Reads the config file and applies its values to the application environment.

  Currently supported keys:

    * `"default_locale"` - default UI language (`"en"` or `"de"`)
    * `"currency"` - currency code shown next to prices (default `"EUR"`)
  """
  def load do
    path = System.get_env("PRESSWERK_CONFIG", @default_path)

    if File.exists?(path) do
      with {:ok, content} <- File.read(path),
           {:ok, config} <- Jason.decode(content) do
        apply(config)
      else
        {:error, reason} ->
          Logger.warning("Could not load config file #{path}: #{inspect(reason)}")
      end
    else
      Logger.warning("Config file not found at #{path}, using defaults")
    end

    :ok
  end

  @doc false
  defp apply(config) when is_map(config) do
    if locale = config["default_locale"] do
      Application.put_env(:presswerk, :default_locale, locale)
    end

    case config["currency"] do
      currency when is_binary(currency) and currency != "" ->
        Application.put_env(:presswerk, :currency, currency)

      _ ->
        :ok
    end
  end

  @doc false
  defp apply(other) do
    Logger.warning("Unexpected config file content, expected a JSON object: #{inspect(other)}")
  end
end
