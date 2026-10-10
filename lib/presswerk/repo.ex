defmodule Presswerk.Repo do
  @moduledoc "Ecto repository for the Presswerk application."
  use Ecto.Repo,
    otp_app: :presswerk,
    adapter: Ecto.Adapters.SQLite3
end
