defmodule MsnrApi.Repo do
  use Ecto.Repo,
    otp_app: :msnr_api,
    adapter: Ecto.Adapters.Postgres
end
