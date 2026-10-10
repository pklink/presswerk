defmodule Presswerk.ConfigTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Presswerk.Config

  describe "load/0" do
    test "loads default_locale from config file" do
      path = tmp_path()
      File.write!(path, ~s({"default_locale": "de"}))
      original_locale = Application.get_env(:presswerk, :default_locale)
      original_config = System.get_env("PRESSWERK_CONFIG")

      try do
        System.put_env("PRESSWERK_CONFIG", path)
        assert :ok = Config.load()
        assert Application.get_env(:presswerk, :default_locale) == "de"
      after
        restore_env(original_locale)
        restore_presswerk_config(original_config)
        File.rm!(path)
      end
    end

    test "loads currency from config file" do
      path = tmp_path()
      File.write!(path, ~s({"currency": "USD"}))
      original_currency = Application.get_env(:presswerk, :currency)
      original_config = System.get_env("PRESSWERK_CONFIG")

      try do
        System.put_env("PRESSWERK_CONFIG", path)
        assert :ok = Config.load()
        assert Application.get_env(:presswerk, :currency) == "USD"
      after
        restore_currency(original_currency)
        restore_presswerk_config(original_config)
        File.rm!(path)
      end
    end

    test "ignores invalid currency values" do
      path = tmp_path()
      File.write!(path, ~s({"currency": ""}))
      original_currency = Application.get_env(:presswerk, :currency)
      original_config = System.get_env("PRESSWERK_CONFIG")

      try do
        System.put_env("PRESSWERK_CONFIG", path)
        Application.delete_env(:presswerk, :currency)
        assert :ok = Config.load()
        assert Application.get_env(:presswerk, :currency) == nil
      after
        restore_currency(original_currency)
        restore_presswerk_config(original_config)
        File.rm!(path)
      end
    end

    test "missing file logs warning and leaves env unchanged" do
      original_locale = Application.get_env(:presswerk, :default_locale)
      original_config = System.get_env("PRESSWERK_CONFIG")

      try do
        System.put_env("PRESSWERK_CONFIG", "config/does_not_exist.json")
        Application.delete_env(:presswerk, :default_locale)

        log = capture_log(fn -> assert :ok = Config.load() end)

        assert log =~ "Config file not found"
        assert log =~ "config/does_not_exist.json"
        assert Application.get_env(:presswerk, :default_locale) == nil
      after
        restore_env(original_locale)
        restore_presswerk_config(original_config)
      end
    end

    test "invalid JSON logs warning and leaves env unchanged" do
      path = tmp_path()
      File.write!(path, "not json")
      original_locale = Application.get_env(:presswerk, :default_locale)
      original_config = System.get_env("PRESSWERK_CONFIG")

      try do
        System.put_env("PRESSWERK_CONFIG", path)
        Application.put_env(:presswerk, :default_locale, "de")

        log = capture_log(fn -> assert :ok = Config.load() end)

        assert log =~ "Could not load config file #{path}"
        assert Application.get_env(:presswerk, :default_locale) == "de"
      after
        restore_env(original_locale)
        restore_presswerk_config(original_config)
        File.rm!(path)
      end
    end

    test "non-object JSON logs warning and does not raise" do
      path = tmp_path()
      File.write!(path, ~s(["not", "an", "object"]))
      original_locale = Application.get_env(:presswerk, :default_locale)
      original_config = System.get_env("PRESSWERK_CONFIG")

      try do
        System.put_env("PRESSWERK_CONFIG", path)
        Application.delete_env(:presswerk, :default_locale)

        log = capture_log(fn -> assert :ok = Config.load() end)

        assert log =~ "Unexpected config file content"
        assert Application.get_env(:presswerk, :default_locale) == nil
      after
        restore_env(original_locale)
        restore_presswerk_config(original_config)
        File.rm!(path)
      end
    end
  end

  defp tmp_path do
    Path.join(
      System.tmp_dir!(),
      "presswerk_config_test_#{System.unique_integer([:positive])}.json"
    )
  end

  defp restore_env(nil), do: Application.delete_env(:presswerk, :default_locale)
  defp restore_env(value), do: Application.put_env(:presswerk, :default_locale, value)

  defp restore_currency(nil), do: Application.delete_env(:presswerk, :currency)
  defp restore_currency(value), do: Application.put_env(:presswerk, :currency, value)

  defp restore_presswerk_config(nil), do: System.delete_env("PRESSWERK_CONFIG")
  defp restore_presswerk_config(value), do: System.put_env("PRESSWERK_CONFIG", value)
end
