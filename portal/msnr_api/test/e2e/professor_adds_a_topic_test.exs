defmodule ProfessorCreatesATopicTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers  
  use Hound.ResponseParser
  #use Hound.Matchers
  
  hound_session()
  
  test "professor can sign in and add a new topic" do
    maximize_window(current_window_handle())

    navigate_to("http://localhost:8080")
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
	header = find_element(:class, "_c7f4942c")
    tabs = find_within_element(header, :class, "_84f7a906")
	all = find_all_within_element(tabs, :class, "_2c839078")
	{tab, others} = List.pop_at(all, 4)
	topics = find_within_element(tab, :tag, "a")
	topics |> click()
	:timer.sleep(3000)
	assert current_path() == "/professor/topics"
	
	fill_field({:id, "Nri-Ui-TextInput-Naslov-teme"}, "Nova Tema")
	find_element(:class, "_b016f64e") |> click()
	:timer.sleep(3000)
	refresh_page()
	:timer.sleep(1000)
	
	maximize_window(current_window_handle())
	take_screenshot("page.png")
	
	body = find_element(:class, "_fd567d89")
	topics = find_all_within_element(body, :class, "_ba485483")
	lastT = List.last(topics)
	topic = find_within_element(lastT, :class, "_8c8496be")
	assert String.contains?(visible_text(topic), "Nova Tema")
	:timer.sleep(3000)
	
	delete_cookies()
  end
end