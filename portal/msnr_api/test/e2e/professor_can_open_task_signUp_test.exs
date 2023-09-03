defmodule ProfessorCreatesChangesActivityInfoTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers  
  use Hound.ResponseParser
  #use Hound.Matchers
  
  hound_session()
  
  test "professor can open a sign up for an activity" do
	#Za ovaj test neophodno je da u bazi postoji aktivnost za koju su zatvorene prijave
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
	row = Enum.find(rows, fn r ->
		data = find_all_within_element(r, :class, "_9818385")
		{doDatum, _others} = List.pop_at(data, 1)
		{open, _others} = List.pop_at(data, 3)
		
		danas = Date.utc_today()
		listaDo = String.split(visible_text(doDatum), ".")
		
		{dan, _} = List.pop_at(listaDo, 0)
		{mesec, _} = List.pop_at(listaDo, 1)
		{godina, _} = List.pop_at(listaDo, 2)
		
		
		if ((visible_text(open) == "Da") and (String.to_integer(dan) >= danas.day) and (String.to_integer(mesec) >= danas.month) and (String.to_integer(godina) >= danas.year)) do
			r
		end
	end
	)
	txtRow = find_all_within_element(row, :class, "_9818385")
	{txtData, _others} = List.pop_at(txtRow, 2)
	txt = visible_text(txtData)
	areaBt = find_within_element(row, :class, "_311c48ca")
	button = find_within_element(areaBt, :class, "_431d219b")
	button |> click()
	:timer.sleep(2000)
	
	
	whole = find_element(:class, "_6ebe79ea")
	changes = find_within_element(whole, :class, "_9ebfe20c")
	btArea = find_within_element(whole, :class, "_e5d31c17")
	
	upNdown = find_within_element(changes, :class, "_210e6684")
	all = find_all_within_element(upNdown, :class, "_d8ec4713")	
	
	{down, _rest} = List.pop_at(all, 1)
	check = find_within_element(down, :id, "nri-ui-switch-with-default-id")
	check |> click()
	:timer.sleep(2000)
	
	save = find_within_element(btArea, :id, "save-btn")
	save |> click()
	:timer.sleep(3000)
	
	txtRow = find_all_within_element(row, :class, "_9818385")
	{txtData, _others} = List.pop_at(txtRow, 3)
	openedTxt = visible_text(txtData)
	
	assert openedTxt == "Da"
	
	#assert
	{tab, _others} = List.pop_at(allTabs, 5)
	asgns = find_within_element(tab, :tag, "a")
	asgns |> click()
	:timer.sleep(3000)
	assert current_path() == "/professor/activities/0/assignments"
	
	side = find_element(:class, "_938412d5")
	finalTxt = txt <> " - " <> "Prijava"
	assert find_within_element(side, :link_text, finalTxt) != nil
	:timer.sleep(3000)
	
	
	delete_cookies()
  end
end