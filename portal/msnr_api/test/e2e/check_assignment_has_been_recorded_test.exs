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
  test "check whether signinUp or signinOff for a assignment was successful" do
    maximize_window(current_window_handle())

    navigate_to("http://localhost:8080")
	:timer.sleep(1000) 
	assert {:ok, _element} = search_element(:link_text, "Prijavi se")
    find_element(:link_text, "Prijavi se") |> click()    
	assert current_path() == "/login"
	fill_field({:id, "Nri-Ui-TextInput-Email"}, "ex1@mail")
	fill_field({:id, "Nri-Ui-TextInput-Password"}, "ex1@mail")
	find_element(:class, "_4d72d302") |> click()
	:timer.sleep(2000)
	
	maximize_window(current_window_handle())
	header = find_element(:class, "_c7f4942c")
    tabs = find_within_element(header, :class, "_84f7a906")
	all = find_all_within_element(tabs, :class, "_2c839078")
	tab = List.last(all)
	asgn = find_within_element(tab, :tag, "a")
	asgn |> click()
	:timer.sleep(3000)
	
	tasks = find_element(:class, "accordion-v3")
	all = find_all_within_element(tasks, :class, "accordion-v3-entry")
	task = Enum.find(all, fn t ->
		tekst = inner_text(t)
		if (String.contains? tekst, "Recenzija - Prijava") do
			t
		end
	end
	)
	tekst = inner_text(task)
	assert (String.contains? tekst, "Recenzija - Prijava")
	btTask = find_within_element(task, :class, "accordion-v3-entry-header")
	btTask |> click()
	:timer.sleep(3000)
	
	section = find_within_element(task, :class, "accordion-v3-entry-panel")
	btPrijava = find_within_element(section, :tag, "button")
	:timer.sleep(1000)
	
	txtBt = visible_text(btPrijava)	
	
	btPrijava |> click()
	:timer.sleep(3000)
	refresh_page()
	:timer.sleep(3000)
	
	navigate_to("http://localhost:8080")
	:timer.sleep(1000) 
	header = find_element(:class, "_c7f4942c")
	btOdjava = find_within_element(header, :class, "_4acf1c22")
	btOdjava |> click()
	:timer.sleep(2000)
	refresh_page()
	:timer.sleep(2000)
	assert {:ok, _element} = search_element(:link_text, "Prijavi se")
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
	tab = List.last(all)
	asgn = find_within_element(tab, :tag, "a")
	asgn |> click()
	:timer.sleep(3000)
	
	side = find_element(:class, "_938412d5")
	all = find_all_within_element(side, :link_text, "Recenzija - Prijava")
	[first | _tail] = all
	first |> click()
	:timer.sleep(3000)
	
	table = find_element(:class, "_d4912e87")
    tbody = find_within_element(table, :tag, "tbody")
	rows = find_all_within_element(tbody, :class, "_265f8938")
	
	row = Enum.find(rows, fn r ->
		data = find_all_within_element(r, :class, "_9818385")
		{name, _others} = List.pop_at(data, 0)
		if (visible_text(name) == "N N") do
			r
		end
	end
	)
	
	data = find_all_within_element(row, :class, "_9818385")
	{name, _others} = List.pop_at(data, 0)
	{done, _others} = List.pop_at(data, 1)
	
	assert visible_text(name) == "N N"
	
	if (txtBt == "Prijavi se") do
		assert visible_text(done) == "Da"
	else
		assert visible_text(done) == "Ne"
	end
	
	delete_cookies()
  end
end