defmodule Gps.Repo do
  use Ecto.Repo,
    otp_app: :gps,
    adapter: Ecto.Adapters.Postgres
end
