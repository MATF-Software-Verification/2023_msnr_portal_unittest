defmodule ProfessorCreatesChangesActivityInfoTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers  
  use Hound.ResponseParser
  #use Hound.Matchers
  
  hound_session()
  
  test "check whether number of activities is the same as number of assignments" do
    #Za ovaj test neophodno je uneti proizvoljan broj aktivnosti u bazu
    maximize_window(current_window_handle())

    navigate_to("http://localhost:8080")
	:timer.sleep(1000) 
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
	allTabs = find_all_within_element(tabs, :class, "_2c839078")
	{tab, _others} = List.pop_at(allTabs, 2)
	activities = find_within_element(tab, :tag, "a")
	activities |> click()
	:timer.sleep(3000)
	assert current_path() == "/professor/activities"
	
	table = find_element(:class, "_d4912e87")
	rows = find_all_within_element(table, :class, "_265f8938")
	lR = length(rows)
	:timer.sleep(2000)
	
	
	{tab, _others} = List.pop_at(allTabs, 5)
	asgns = find_within_element(tab, :tag, "a")
	asgns |> click()
	:timer.sleep(3000)
	assert current_path() == "/professor/activities/0/assignments"
	
	side = find_element(:class, "_938412d5")
	allActivities = find_all_within_element(side, :tag, "a")
	lAct = length(allActivities)
	
	assert lR == lAct
	
	delete_cookies()
  end
end