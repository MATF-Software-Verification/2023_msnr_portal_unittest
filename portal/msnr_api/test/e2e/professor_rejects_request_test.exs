defmodule ProfessorRejectsStudentRequestTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers  
  use Hound.ResponseParser
  #use Hound.Matchers
  
  setup do
    Hound.start_session
    :ok
  end

  @tag timeout: 800000
  test "professor can sign in and reject a student pending and check if mail has been sent" do
    maximize_window(current_window_handle())

    # pravljenje naloga
    navigate_to("http://localhost:8080")

    napravi_nalog = find_element(:class, "_b016f64e")
    napravi_nalog |> click()

    :timer.sleep(3000)
    assert current_url() == "http://localhost:8080/register"

	:timer.sleep(1000)	
	assert current_path() == "/register"
	fill_field({:id, "Nri-Ui-TextInput-Email"}, "reject@example.com")
	fill_field({:id, "Nri-Ui-TextInput-Ime"}, "Reject")
	fill_field({:id, "Nri-Ui-TextInput-Prezime"}, "Reject")
	fill_field({:id, "Nri-Ui-TextInput-Broj-indeksa"}, "113/2021")
	find_element(:class, "_4d72d302") |> click()
	assert String.contains?(visible_text(find_element(:class, "_fab610da")), "Uspešno ste podneli prijavu! 👍")
	:timer.sleep(6000)
	
    navigate_to("http://localhost:8080/")
	:timer.sleep(1000) 
	assert {:ok, element} = search_element(:link_text, "Prijavi se")
	size = window_size(current_window_handle())
    find_element(:link_text, "Prijavi se") |> click()    
	assert current_path() == "/login"
	fill_field({:id, "Nri-Ui-TextInput-Email"}, "test@professor")
	fill_field({:id, "Nri-Ui-TextInput-Password"}, "test")
	find_element(:class, "_4d72d302") |> click()
	:timer.sleep(2000)
	
	maximize_window(current_window_handle())
    navigate_to("http://localhost:8080/professor/registrations")
	assert current_path() == "/professor/registrations"
	:timer.sleep(3000)

	dugmici = find_element(:class, "_b256c6dd")
    odbaci = find_within_element(dugmici, :class, "_d3f97055")
    odbaci |> click()
    :timer.sleep(6000)

    take_screenshot("1.png")

    confirm = find_element(:class, "_6ebe79ea")
    potvrdi = find_within_element(confirm, :class, "_4acf1c22")
    potvrdi |> click()
    :timer.sleep(6000)

    take_screenshot("2.png")

    odbijeni = find_element(:class, "_d4f911eb")
    odbijeni |> click()
    :timer.sleep(6000)

    take_screenshot("3.png")

    svi_odbijeni = find_element(:id, "tab-body-rejected")

    odbijen_st = find_all_within_element(svi_odbijeni, :class, "_8c8496be")
    assert String.contains?(page_source(), "reject@example.com")
	
	navigate_to("http://localhost:4000/dev/mailbox/")
	
	parent_element = find_element(:class, "list-group")

	mails = find_all_within_element(parent_element, :tag, "a")
	
    last_mail = List.first(mails)
    last_mail |> click()
    take_screenshot("mail.png")
    
    :timer.sleep(6000)
	
	assert String.contains?(page_source(), "reject@example.com")

    take_screenshot("mail_body.png")
	delete_cookies()
  end
end