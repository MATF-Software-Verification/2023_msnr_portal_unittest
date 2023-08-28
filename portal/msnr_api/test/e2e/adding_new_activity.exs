defmodule MsnrApi.LoginTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers
  
  alias MsnrApi.StudentRegistrations
  import MsnrApi.SemestersFixtures

  hound_session()

  test "adding new activity" do
    [hand | all] = window_handles()
    set_window_size(hand, 1920, 1080)

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
    navigate_to("http://localhost:8080/professor/activities")
    :timer.sleep(6000)
    
    assert current_url() == "http://localhost:8080/professor/activities"

    btn = find_element(:class, "_431d219b")
    btn |> click()
    
    :timer.sleep(6000)

    formf = find_element(:class, "_88c6178e")
    dates = find_all_within_element(formf, :class, "_bf3f5e20")
    [startd | endd] = dates
    [endd | _] = endd

    start = find_within_element(startd, :id, "start-date-activity")
	dead_line = find_within_element(endd, :tag, "input")
    
    start |> fill_field(Date.utc_today())
    dead_line |> fill_field(Date.utc_today())
    
    form2 = find_element(:class, "_21460236")
    sel = find_within_element(form2, :tag, "select")
    sel |> click()
    find_within_element(sel, :id, "nri-select-3") |> click()

    # take_screenshot("scr/formica.png")

    form3 = find_element(:class, "_1c118298")
    inp = find_within_element(form3, :tag, "input")
    inp |> fill_field("10")

    save = find_element(:id, "save-btn")
    save |> click()

    :timer.sleep(6000)

    tab = find_element(:class, "_265f8938")
    col = find_all_within_element(tab, :class, "_9818385")
    [_|[_|[tip|_]]] = col

    alert_text = visible_text(tip)
    assert alert_text == "CV"

    # take_screenshot("scr/act_page.png")
  end
end