defmodule MultiBrowserSession do
  use ExUnit.Case
  use Hound.Helpers

  hound_session()

  test "should be able to run multiple sessions" do
    url1 = "http://localhost:8080/page1.html"
    url2 = "http://localhost:8080/page2.html"

    # Navigate to a url
    navigate_to(url1)

    # Change to another session
    change_session_to :another_session
    # Navigate to a url in the second session
    navigate_to(url2)
    # Then assert url
    assert url2 == current_url()

    # Now go back to the default session
    change_to_default_session()
    # Assert if the url is the one we visited
    assert url1 == current_url()
  end
end

defmodule WelcomePageTest do
  use MsnrApiWeb.ConnCase
  use Hound.Helpers  
  
  hound_session()  
  
  test "page has a correct title" do
    navigate_to("http://localhost:8080/")    
	assert page_title() == "MSNR"
    assert String.contains?(page_source(), "MSNR")
  end
end