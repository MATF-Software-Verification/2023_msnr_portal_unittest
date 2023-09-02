defmodule MsnrApi.LoginTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers

  hound_session()

  @tag timeout: 80000
  test "registration" do
    maximize_window(current_window_handle())

    # pravljenje naloga
    navigate_to("http://localhost:8080")

    napravi_nalog = find_element(:class, "_b016f64e")
    napravi_nalog |> click()

    :timer.sleep(3000)
    assert current_url() == "http://localhost:8080/register"

    form = find_element(:class, "_c69dad1f")
    email = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
    ime = find_within_element(form, :id, "Nri-Ui-TextInput-Ime")
    prezime = find_within_element(form, :id, "Nri-Ui-TextInput-Prezime")
    indeks = find_within_element(form, :id, "Nri-Ui-TextInput-Broj-indeksa")
    submit = find_within_element(form, :class, "_4d72d302")

    email |> fill_field("vanja@gmail.com")
    ime |> fill_field("vanja")
    prezime |> fill_field("vanjic")
    indeks |> fill_field("7474")
    submit |> click()
    :timer.sleep(6000)

    # prihvatanje naloga
    navigate_to("http://localhost:8080")
    bt = find_element(:link_text, "Prijavi se")
    bt |> click()

    assert current_url() == "http://localhost:8080/login"

    form = find_element(:class, "_e90e6910")
    em = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	ps = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    sub = find_within_element(form, :class, "_4d72d302")
    
    em |> fill_field("test@professor")
    ps |> fill_field("test")
    sub |> click()
    :timer.sleep(6000)

    assert current_url() == "http://localhost:8080/"
    navigate_to("http://localhost:8080/professor/registrations")
    :timer.sleep(3000)

    prihvati = find_element(:class, "_b256c6dd")
    prihvati = find_within_element(prihvati,:class, "_4acf1c22")
    prihvati |> click()
    :timer.sleep(6000)

    alrt = find_element(:class, "_6ebe79ea")
    potvrdi = find_within_element(alrt, :class, "_4acf1c22")
    potvrdi |> click()
    :timer.sleep(6000)

    prihvaceni = find_element(:id, "accepted")
    prihvaceni |> click()
    :timer.sleep(6000)

    svi_prihvaceni = find_element(:id, "tab-body-pending")
    # take_screenshot("accepted.png")
    navigate_to("http://localhost:4000/api/semesters/1/registrations")
    
    assert String.contains?(page_source(), "{\"email\":\"vanja@gmail.com\",\"first_name\":\"vanja\",")
    assert String.contains?(page_source(), "\"index_number\":\"7474\",\"last_name\":\"vanjic\",\"status\":\"accepted\"}")

    navigate_to("http://localhost:4000/dev/mailbox/")

    last_email = find_element(:class, "list-group-item")
    last_email |> click()
    
    body = find_element(:class, "body")
    a = find_within_element(body, :tag, "a")
    href = attribute_value(a, "href")
    navigate_to(href)
    :timer.sleep(6000)

    a = find_element(:tag, "a")
    href = attribute_value(a, "href")
   
    Hound.Helpers.Session.end_session()
    Hound.Helpers.Session.start_session()
    navigate_to(href)

    :timer.sleep(6000)

    form = find_element(:class, "_c69dad1f")
    email = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
    lozinka = find_within_element(form, :id, "Nri-Ui-TextInput-Lozinka")
    lozinka2 = find_within_element(form, :id, "Nri-Ui-TextInput-Potvrda-lozinke")
    sub = find_within_element(form, :class, "_f36c1748")
    
    email |> fill_field("vanja@gmail.com")
    lozinka  |> fill_field("vanja123")
    lozinka2 |> fill_field("vanja123")
    sub |> click()
    :timer.sleep(6000)
    
    navigate_to("http://localhost:4000/api/semesters/1/registrations")
    assert String.contains?(page_source(), "{\"email\":\"vanja@gmail.com\",\"first_name\":\"vanja\",")
    assert String.contains?(page_source(), "\"index_number\":\"7474\",\"last_name\":\"vanjic\"")

  end
end