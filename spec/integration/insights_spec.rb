require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Insights" do
   it "clicks on the insights link on the home page" do
    login(users(:owner))
    within ".activity_list_header" do
      click_link "Insights"
      find(".title h1").should have_content("Insights")
    end
  end

  it "creates an insight" do
    login(users(:owner))

    workspace_name = workspaces(:public).name
    within ".dashboard_workspace_list.list" do
      find("a", :text => /^#{workspace_name}$/).click()
    end

    find("div.sidebar_content.primary").should have_content(workspace_name)
    click_link "Add an insight"

    within_modal do
      set_cleditor_value("body", "This is adding an Insight")
      click_button "Add Insight"
    end
  end
end

describe "Insight Operations" do
  it "comments on an insight" do
    login(users(:owner))
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "insight-test"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    find("div.sidebar_content.primary").should have_content("insight-test")
    click_link "Add an insight"
    within_modal do
      set_cleditor_value("body", "This is a test on adding an insight")
      click_button "Add Insight"
    end
    page.should have_content("This is a test on adding an insight")
    find("li", :text => "This is a test on adding an insight").click_link "Comment"
    within_modal do
      set_cleditor_value("body", "Comment on an insight")
      click_button "Add Comment"
    end
    page.should have_content("Comment on an insight")
  end

  it "edits an insight" do
    login(users(:owner))
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "insight-test"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    find("div.sidebar_content.primary").should have_content("insight-test")
    click_link "Add an insight"
    within_modal do
      set_cleditor_value("body", "This is a test on editing an insight")
      click_button "Add Insight"
    end
    page.should have_content("This is a test on editing an insight")
    find("li", :text => "This is a test on editing an insight").click_link "Edit"
    within_modal do
      set_cleditor_value("body", "Edit insight")
      click_button "Save Changes"
    end
    page.should have_content("Edit insight")
  end

  it "deletes an insight" do
    login(users(:owner))
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "insight-test"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    find("div.sidebar_content.primary").should have_content("insight-test")
    click_link "Add an insight"
    within_modal do
      set_cleditor_value("body", "delete insight")
      click_button "Add Insight"
    end
    page.should have_content("delete insight")
    find("li", :text => "delete insight").click_link "Delete"
    within_modal do
      click_button "Delete Insight"
    end
    page.should_not have_content("delete insight")
  end

  it "publishes the insight to the Insights page" do
    login(users(:owner))
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "insight-test"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    find("div.sidebar_content.primary").should have_content("insight-test")
    click_link "Add an insight"
    within_modal do
      set_cleditor_value("body", "publishes insight to the insight page")
      click_button "Add Insight"
    end
    page.should have_content("publishes insight to the insight page")
    find("li", :text => "publishes insight to the insight page").click_link "Publish"
    within_modal do
      click_button "Publish Insight"
    end
    click_link "Home"
    within ".activity_list_header" do
      click_link "Insights"
      find(".title h1").should have_content("Insights")
    end
    page.should have_content"publishes insight to the insight page"
  end

  it "unpublishes the insight to the Insights page" do
    login(users(:owner))
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "insight-test"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    find("div.sidebar_content.primary").should have_content("insight-test")
    click_link "Add an insight"
    within_modal do
      set_cleditor_value("body", "unpublishes insight to the insight page")
      click_button "Add Insight"
    end
    page.should have_content("unpublishes insight to the insight page")
    find("li", :text => "unpublishes insight to the insight page").click_link "Publish"
    within_modal do
      click_button "Publish Insight"
    end
    find("li", :text => "unpublishes insight to the insight page").click_link "Unpublish"
    within_modal do
      click_button "Unpublish Insight"
    end
    click_link "Home"
    within ".activity_list_header" do
      click_link "Insights"
      find(".title h1").should have_content("Insights")
    end
    page.should_not have_content"unpublishes insight to the insight page"
  end

end
