defmodule MsnrApi.LoginTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers

  hound_session()

  @tag timeout: 80000
  test "grupna aktivnost" do
    maximize_window(current_window_handle())
    
    # podrezumevamo da u bazi postoji registrovan korisnik i napravljena prva aktivnost 'grupa'
    # za koju traje prijava

    # prijava kao registrovani student
    navigate_to("http://localhost:8080")
    prijavi_se = find_element(:link_text, "Prijavi se")
    prijavi_se |> click()

    assert current_url() == "http://localhost:8080/login"

    form = find_element(:class, "_e90e6910")
    email = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	password = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    submit = find_within_element(form, :class, "_4d72d302")
    
    email |> fill_field("boris")
    password |> fill_field("boris")
    submit |> click()
    :timer.sleep(6000)

    assert current_url() == "http://localhost:8080/"

    # prijava za aktivnost grupa
    navigate_to("http://localhost:8080/student")
    
    activity_list = find_element(:class, "_afa2b4cc")
    group = find_within_element(activity_list, :tag, "button")
    group |> click()
    :timer.sleep(6000)
    
    form = find_element(:class, "_afa2b4cc")
    prijavi_se = find_within_element(form, :class, "_4acf1c22")
    prijavi_se |> click()
    :timer.sleep(6000)
    
    # odjava studenta
    header = find_element(:class, "_c7f4942c")
    odjavi_se = find_within_element(header, :class, "_4acf1c22")
    odjavi_se |> click()

    # prijava profesora
    prijavi_se = find_element(:link_text, "Prijavi se")
    prijavi_se |> click()

    form = find_element(:class, "_e90e6910")
    email = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	password = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    submit = find_within_element(form, :class, "_4d72d302")
    
    email |> fill_field("test@professor")
    password |> fill_field("test")
    submit |> click()
    :timer.sleep(6000)
    
    # izmena aktivnosti, iskljucivanje prijave
    navigate_to("http://localhost:8080/professor/activities")

    aktivnosti = find_element(:class, "_d4912e87")
    aktivnost_grupa = find_within_element(aktivnosti, :class, "_265f8938")
    izmeni = find_within_element(aktivnost_grupa, :class, "_431d219b")
    izmeni |> click()
    :timer.sleep(3000)
    take_screenshot("izm.png")
    
    izmeni_prozor = find_element(:class, "_fe9e94eb")
    bodovi = find_within_element(izmeni_prozor, :id, "Nri-Ui-TextInput-Broj-poena")
    bodovi |> fill_field("20")
    :timer.sleep(3000)

    sacuvaj = find_element(:id, "save-btn")
    sacuvaj |> click()
    :timer.sleep(3000)

    # odjava profesora
    header = find_element(:class, "_c7f4942c")
    odjavi_se = find_within_element(header, :class, "_4acf1c22")
    odjavi_se |> click()

    bt = find_element(:link_text, "Prijavi se")
    bt |> click()

    # prijava studenta
    form = find_element(:class, "_e90e6910")
    em = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	ps = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    sub = find_within_element(form, :class, "_4d72d302")
    
    em |> fill_field("boris")
    ps |> fill_field("boris")
    sub |> click()
    :timer.sleep(6000)

    # ptavljenje grupe
    navigate_to("http://localhost:8080/student")
    
    activity_list = find_element(:class, "_afa2b4cc")
    group = find_within_element(activity_list, :tag, "button")
    group |> click()
    :timer.sleep(6000)
    
    # biranje prvo dvoje kolega sa spiska onih koji nemaju grupu
    student_list = find_element(:class, "_d4912e87")
    kolege = find_all_within_element(student_list, :class, "_b4b9067e")
    
    [prvi_kolega | ostali] = kolege
    [drugi_kolega | _ ] = ostali

    prvi_kolega |> click()
    drugi_kolega |> click()

    footer = find_element(:class, "_b11429db")
    prijavi_grupu = find_within_element(footer, :class, "_4acf1c22")
    prijavi_grupu |> click()
    
    :timer.sleep(6000)
    
    # provera da li student postoji u tabeli grupa
    navigate_to("http://localhost:4000/api/semesters/1/groups")
    assert String.contains?(page_source(), "{\"email\":\"boris\",\"first_name\":\"boris\",\"group_id\"")
    

  end
end