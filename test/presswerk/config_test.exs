defmodule Presswerk.ConfigTest do
  use ExUnit.Case, async: false

  alias Presswerk.Config

  describe "load/0" do
    test "loads default_locale from config file" do
      path = Path.join(System.tmp_dir!(), "presswerk_config_test_#{:rand.uniform(999_999)}.json")
      File.write!(path, ~s({"default_locale": "de"}))

      original = Application.get_env(:presswerk, :default_locale)

      try do
        System.put_env("PRESSWERK_CONFIG", path)
        assert :ok = Config.load()
        assert Application.get_env(:presswerk, :default_locale) == "de"
      after
        restore_env(original)
        System.delete_env("PRESSWERK_CONFIG")
        File.rm!(path)
      end
    end

    test "missing file does not raise and leaves env unchanged" do
      original = Application.get_env(:presswerk, :default_locale)

      try do
        System.put_env("PRESSWERK_CONFIG", "config/does_not_exist.json")
        Application.delete_env(:presswerk, :default_locale)

        assert :ok = Config.load()
        assert Application.get_env(:presswerk, :default_locale) == nil
      after
        restore_env(original)
        System.delete_env("PRESSWERK_CONFIG")
      end
    end

    test "invalid JSON logs warning and does not raise" do
      path = Path.join(System.tmp_dir!(), "presswerk_config_test_#{:rand.uniform(999_999)}.json")
      File.write!(path, "not json")

      try do
        System.put_env("PRESSWERK_CONFIG", path)
        assert :ok = Config.load()
      after
        System.delete_env("PRESSWERK_CONFIG")
        File.rm!(path)
      end
    end
  end

  defp restore_env(nil), do: Application.delete_env(:presswerk, :default_locale)
  defp restore_env(value), do: Application.put_env(:presswerk, :default_locale, value)
end
