defmodule ProfessorCreatesChangesActivityInfoTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers  
  use Hound.ResponseParser
  #use Hound.Matchers
  
  hound_session()
  
  test "professor can sign in and change information for an activity" do
	#Za ovaj test je neophodno imati unetu barem aktivnost "Finalna verzija rada" u bazi
    maximize_window(current_window_handle())

    # logovanje profesora
    navigate_to("http://localhost:8080")
	:timer.sleep(1000) 
	assert {:ok, _element} = search_element(:link_text, "Prijavi se")
    find_element(:link_text, "Prijavi se") |> click()    
	assert current_path() == "/login"
	fill_field({:id, "Nri-Ui-TextInput-Email"}, "test@professor")
	fill_field({:id, "Nri-Ui-TextInput-Password"}, "test")
	find_element(:class, "_4d72d302") |> click()
	:timer.sleep(2000)

	# biramo tab sa aktivnostima
	maximize_window(current_window_handle())
	header = find_element(:class, "_c7f4942c")
    tabs = find_within_element(header, :class, "_84f7a906")
	all = find_all_within_element(tabs, :class, "_2c839078")
	{tab, _others} = List.pop_at(all, 2)
	activities = find_within_element(tab, :tag, "a")
	activities |> click()
	:timer.sleep(3000)
	assert current_path() == "/professor/activities"
	
	table = find_element(:class, "_d4912e87")
	rows = find_all_within_element(table, :class, "_265f8938")
	row = Enum.find(rows, fn r ->
		data = find_all_within_element(r, :class, "_9818385")
		{name, _others} = List.pop_at(data, 2)
		if (visible_text(name) == "Finalna vezija rada") do
			r
		end
	end
	)
	areaBt = find_within_element(row, :class, "_311c48ca")
	button = find_within_element(areaBt, :class, "_431d219b")
	button |> click()
	:timer.sleep(2000)
	
	# menjanje aktivnosti
	whole = find_element(:class, "_6ebe79ea")
	changes = find_within_element(whole, :class, "_9ebfe20c")
	btArea = find_within_element(whole, :class, "_e5d31c17")
	
	upNdown = find_within_element(changes, :class, "_210e6684")
	all = find_all_within_element(upNdown, :class, "_d8ec4713")
	{upper, _rest} = List.pop_at(all, 0)
	
	from = find_within_element(upper, :id, "start-date-activity")
	
	div_all = find_all_within_element(upper, :class, "_bf3f5e20")
	{second, _others} = List.pop_at(div_all, 1)
	to = find_within_element(second, :tag, "input")

	# unosenje novih datuma za aktivnost
	fill_field(from, "09/04/2023")
	fill_field(to, "09/17/2023")

	# menjanje polja prijava	
	{down, _rest} = List.pop_at(all, 1)
	check = find_within_element(down, :id, "nri-ui-switch-with-default-id")
	check |> click()
	:timer.sleep(1000)
	
	save = find_within_element(btArea, :id, "save-btn")
	save |> click()
	:timer.sleep(3000)
	refresh_page()
	:timer.sleep(1000)
	
	#assert
	table = find_element(:class, "_d4912e87")
	rows = find_all_within_element(table, :class, "_265f8938")
	row = Enum.find(rows, fn r ->
		data = find_all_within_element(r, :class, "_9818385")
		{name, _others} = List.pop_at(data, 2)
		if (visible_text(name) == "Finalna vezija rada") do
			r
		end
	end
	)

	# provera da li su dobro izmenjeni podaci
	data = find_all_within_element(row, :class, "_9818385")
	{changed1, _others} = List.pop_at(data, 0)
	{changed2, _others} = List.pop_at(data, 1)
	{changed3, _others} = List.pop_at(data, 3)
	assert String.contains?(visible_text(changed1), "04.09.2023.")
	assert String.contains?(visible_text(changed2), "17.09.2023.")
	assert String.contains?(visible_text(changed3), "Da")
	:timer.sleep(1000)
	
	delete_cookies()
  end
end
