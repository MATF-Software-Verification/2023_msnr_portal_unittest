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
  test "professor can sign in and grade an assignment if it is possible to grade it" do
	#Za ovaj test neophodno je da u bazi postoji barem jedna aktivnost za koju su prijave zatvorene i da postoje studenti koji su se prijavili za tu aktivnost
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

        # biramo poslednji tab
	maximize_window(current_window_handle())
	header = find_element(:class, "_c7f4942c")
    tabs = find_within_element(header, :class, "_84f7a906")
	all = find_all_within_element(tabs, :class, "_2c839078")
	tab = List.last(all)
	asgn = find_within_element(tab, :tag, "a")
	asgn |> click()
	:timer.sleep(3000)

	# nadjemo trazenu aktivnost
	side = find_element(:class, "_938412d5")
	all = find_all_within_element(side, :tag, "a")
	#all = find_all_within_element(side, :link_text, "Recenzija")
	row = Enum.find(all, fn r ->
		data = visible_text(r)
		
		if (!(String.contains?(data, "Prijava"))) do
			r
		end
	end
	)
	row |> click()
	:timer.sleep(3000)
	
	table = find_element(:class, "_d4912e87")
    tbody = find_within_element(table, :tag, "tbody")
	rows = find_all_within_element(tbody, :class, "_265f8938")


	# nadjemo studente koji nema ocenu
	not_graded = Enum.filter(rows, fn r ->
		data = find_all_within_element(r, :class, "_9818385")
		{done, _others} = List.pop_at(data, 1)
		{grade, _others} = List.pop_at(data, 2)
		{comm, _others} = List.pop_at(data, 3)
		if ((visible_text(done) == "Da") and (visible_text(grade) == "") and (visible_text(comm) == "")) do
			row
		end
	end
	)

	# ocenjujemo studenta
	{first, _others} = List.pop_at(not_graded, 0)
	td = find_within_element(first, :class, "_311c48ca")
	div = find_within_element(td, :class, "_324310c2") 
	grade = find_within_element(div, :class, "_431d219b")
	grade |> click()
	:timer.sleep(3000)
	dialog = find_element(:class, "_6ebe79ea")
	comment = find_within_element(dialog, :id, "Nri-Ui-TextInput-Komentar")
	fill_field(comment, "Odlicno")
	points = find_within_element(dialog, :id, "Nri-Ui-TextInput-Broj-poena")
	fill_field(points, "20")
	div_save = find_element(:class, "_e5d31c17")
	save = find_within_element(div_save, :id, "save-btn")
	save |> click()
	:timer.sleep(4000)
	refresh_page()
	:timer.sleep(4000)
	
	# provera unete ocene
	table = find_element(:class, "_d4912e87")
    tbody = find_within_element(table, :tag, "tbody")
	rows = find_all_within_element(tbody, :class, "_265f8938")
	row = List.last(rows)
	data = find_all_within_element(row, :class, "_9818385")
	{o, _others} = List.pop_at(data, 2)
	{k, _others} = List.pop_at(data, 3)
	assert visible_text(o) == "20"
	assert visible_text(k) == "Odlicno"
	
	delete_cookies()
  end
end
