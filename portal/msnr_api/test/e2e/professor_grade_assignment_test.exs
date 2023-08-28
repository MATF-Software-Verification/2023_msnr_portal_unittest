defmodule ProfessorGradesAnAssignmentTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers  
  use Hound.ResponseParser
  #use Hound.Matchers
  
  setup do
    Hound.start_session
    :ok
  end

  @tag timeout: 800000
  test "professor can sign in and grade an assignment" do
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
    #navigate_to("http://localhost:8080/professor/registrations")
	#assert current_path() == "/professor/registrations"
	header = find_element(:class, "_c7f4942c")
    tabs = find_within_element(header, :class, "_84f7a906")
	all = find_all_within_element(tabs, :class, "_2c839078")
	tab = List.last(all)
	asgn = find_within_element(tab, :tag, "a")
	#tab = List.last(tabs)
	#assignments = find_within_element(tab, :tag, "a")
	asgn |> click()
	:timer.sleep(3000)
	
	side = find_element(:class, "_938412d5")
	all = find_all_within_element(side, :tag, "a")
	[first | tail] = all
	[second | _tail] = tail 
	second |> click()
	:timer.sleep(3000)
	
	table = find_element(:class, "_d4912e87")
    tbody = find_within_element(table, :tag, "tbody")
	rows = find_all_within_element(tbody, :class, "_265f8938")
	row = List.last(rows)
	grade = find_within_element(row, :class, "_431d219b")
	grade |> click()
	:timer.sleep(3000)
	
	dialog = find_element(:class, "_6ebe79ea")
    comment = find_within_element(dialog, :id, "Nri-Ui-TextInput-Komentar")
	fill_field(comment, "Prihvatljivo")
	points = find_within_element(dialog, :id, "Nri-Ui-TextInput-Broj-poena")
	fill_field(points, "13")
	div_save = find_element(:class, "_e5d31c17")
	save = find_within_element(div_save, :id, "save-btn")
	save |> click()
	refresh_page()
	:timer.sleep(4000)
	
	table = find_element(:class, "_d4912e87")
    tbody = find_within_element(table, :tag, "tbody")
	rows = find_all_within_element(tbody, :class, "_265f8938")
	row = List.last(rows)
	data = find_all_within_element(row, :class, "_9818385")
	[first | tail] = data
	[second | tail1] = tail 
	[p | tail2] = tail1
	assert String.contains?(visible_text(p), "13")
	[c | n] = tail2
	assert String.contains?(visible_text(c), "Prihvatljivo")
	:timer.sleep(3000)
	
	delete_cookies()
  end
end