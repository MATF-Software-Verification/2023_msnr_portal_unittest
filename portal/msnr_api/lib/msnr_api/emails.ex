defmodule MsnrApi.Emails do
  import Swoosh.Email
  alias MsnrApi.Accounts.User
  alias MsnrApi.StudentRegistrations.StudentRegistration

  @from "msnr-admin@test.com"
  @password_url "http://localhost:8080/setPassword/"

  def accept(%User{} = user) do
    new()
    |> to(user.email)
    |> from(@from)
    |> subject("[MSNR] Prihvaćen zahtev za registraciju")
    |> html_body(~s"""
    <p>Zdravo #{user.first_name},<p>

    <p>Vaš zahtev za kreiranje naloga je prihvaćen.</p>
    <p>Podesite Vašu lozinku <a href="#{@password_url <> user.password_url_path}" target="_blank">
    ovde</a>.</p>
    """)
  end

  def reject(%StudentRegistration{} = registration) do
    new()
    |> to(registration.email)
    |> from(@from)
    |> subject("[MSNR] Odbijen zahtev za registraciju")
    |> html_body(~s"""
    <p>Zdravo #{registration.first_name},<p>

    <p>Vas zahtev za kreiranje naloga je odbijen.</p>
    <p>Kontaktirajte profesora ukoliko imate dodatnih pitanja.</p>
    """)
  end
end
