defmodule Presswerk.Repo do
  use Ecto.Repo,
    otp_app: :presswerk,
    adapter: Ecto.Adapters.SQLite3
end
