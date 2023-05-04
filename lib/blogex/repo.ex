defmodule Blogex.Repo do
  use Ecto.Repo,
    otp_app: :blogex,
    adapter: Ecto.Adapters.Postgres
end
