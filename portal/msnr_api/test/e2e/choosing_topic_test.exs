defmodule MsnrApi.LoginTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers

  @tag timeout: 80000
  hound_session()
  test "biranje tema za grupni rad" do
    maximize_window(current_window_handle())
    
    # podrezumevamo da u bazi postoji registrovan korisnik koji je u nekoj grupi,
    # lista tema i aktivnost za prijavu tema (pored grupe kao aktivnost)
    
    # logovanje kao student
    navigate_to("http://localhost:8080")
    bt = find_element(:link_text, "Prijavi se")
    bt |> click()
    
    assert current_url() == "http://localhost:8080/login"

    form = find_element(:class, "_e90e6910")
    em = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	ps = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    sub = find_within_element(form, :class, "_4d72d302")
    
    em |> fill_field("nina@gmail.com")
    ps |> fill_field("nina")
    sub |> click()
    :timer.sleep(6000)

    assert current_url() == "http://localhost:8080/"


    # prijavljivanje za aktivnost 'Tema rada'
    navigate_to("http://localhost:8080/student")
    
    activity_list = find_element(:class, "accordion-v3")
    act = find_all_within_element(activity_list, :tag, "button")
    [_ | ssbtn] = act
    [sbtn | _] = ssbtn
    sbtn |> click()
    :timer.sleep(6000)
    
    form = find_element(:class, "_afa2b4cc")
    prijavi_se = find_within_element(form, :class, "_4acf1c22")
    prijavi_se |> click()
    :timer.sleep(6000)
    
    # odjavljivanje studenta
    header = find_element(:class, "_c7f4942c")
    odjavi_se = find_within_element(header, :class, "_4acf1c22")
    odjavi_se |> click()

    # logovanje profesora
    bt = find_element(:link_text, "Prijavi se")
    bt |> click()

    form = find_element(:class, "_e90e6910")
    em = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	ps = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    sub = find_within_element(form, :class, "_4d72d302")
    
    em |> fill_field("test@professor")
    ps |> fill_field("test")
    sub |> click()
    :timer.sleep(6000)
    
    # izmena aktivnosti tako da vise nije prijava
    navigate_to("http://localhost:8080/professor/activities")
    
    activity_list = find_element(:class, "_d4912e87")
    act = find_all_within_element(activity_list, :tag, "button")
    [_ | ssbtn] = act
    [sbtn | _] = ssbtn
    sbtn |> click()
    :timer.sleep(6000)
    
    izmeni_prozor = find_element(:class, "_fe9e94eb")
    bodovi = find_within_element(izmeni_prozor, :id, "Nri-Ui-TextInput-Broj-poena")
    bodovi |> fill_field("20")
    :timer.sleep(3000)

    sacuvaj = find_element(:id, "save-btn")
    sacuvaj |> click()
    :timer.sleep(3000)

    # odjavljivanje profesora
    header = find_element(:class, "_c7f4942c")
    odjavi_se = find_within_element(header, :class, "_4acf1c22")
    odjavi_se |> click()

    # logovanje studenta
    bt = find_element(:link_text, "Prijavi se")
    bt |> click()

    form = find_element(:class, "_e90e6910")
    em = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	ps = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    sub = find_within_element(form, :class, "_4d72d302")
    
    em |> fill_field("nina@gmail.com")
    ps |> fill_field("nina")
    sub |> click()
    :timer.sleep(6000)

    # otvaranje aktivnosti 'Teme rada' kako bi izabrali prvu temu
    navigate_to("http://localhost:8080/student")
    
    activity_list = find_element(:class, "accordion-v3")
    act = find_all_within_element(activity_list, :tag, "button")
    [_ | ssbtn] = act
    [sbtn | _] = ssbtn
    sbtn |> click()
    :timer.sleep(6000)
    
    topics_list = find_element(:class, "_fd567d89")
    topic_name = find_within_element(topics_list, :class, "_8c8496be")
    topic = find_within_element(topics_list, :class, "_b4b9067e")
    
    topic_name = inner_text(topic_name)
    topic |> click()

    # odjavljivanje studenta
    header = find_element(:class, "_c7f4942c")
    odjavi_se = find_within_element(header, :class, "_4acf1c22")
    odjavi_se |> click()

    bt = find_element(:link_text, "Prijavi se")
    bt |> click()

    # logovanje profesora
    form = find_element(:class, "_e90e6910")
    em = find_within_element(form, :id, "Nri-Ui-TextInput-Email")
	ps = find_within_element(form, :id, "Nri-Ui-TextInput-Password")
    sub = find_within_element(form, :class, "_4d72d302")
    
    em |> fill_field("test@professor")
    ps |> fill_field("test")
    sub |> click()
    :timer.sleep(6000)
    
    # provera da li je tema izabrana
    navigate_to("http://localhost:8080/professor/groups")
    :timer.sleep(3000)
    assert String.contains?(page_source(), topic_name)
    
  end
end