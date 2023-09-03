defmodule MsnrApi.LoginTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers

  hound_session()

  test "greska pri registraciji" do
    navigate_to("http://localhost:8080/register")

    form = find_element(:class, "_c69dad1f")
    username = find_within_element(form, :id, "Nri-Ui-TextInput-Ime")
    submit = find_within_element(form, :class, "_4d72d302")

    # ne popunjavano sva polja
    username |> fill_field("Ana")
    submit |> click()

    alert = find_element(:class, "_fab610da")
    alert_text = visible_text(alert)

    assert alert_text == "Došlo je do neočekivane greške 😞"

    assert current_url() == "http://localhost:8080/register"

  end
end