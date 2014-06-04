require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Workspaces" do
  before do
    login(users(:admin))
  end
  let(:workspace) { workspaces(:public) }

  describe "creates a milestone" do
    it "creates a milestone" do
      visit('#/workspaces')
      click_button "Create Workspace"
      within_modal do
        fill_in 'name', :with => "mile-stone"
        click_button "Create Workspace"
      end
      click_link "Dismiss the workspace quick start guide"
      page.should have_content('All Activity')
      Workspace.find_by_name("mile-stone").should_not be_nil
      click_link "Milestones"
      click_button "Create"
      within_modal do
        find('.name').set("milestone1")
        click_button "Create"
      end
      page.should have_content("milestone1")
    end
  end

  describe "finishes a milestone" do
    it "finishes a milestone" do
      visit("#/workspaces/#{workspace.id}")
      click_link "Milestones"
      find("li", :text => "Milestone 44450").click
      find("div.sidebar_content.primary").should have_content("Milestone 44450")
      click_link "Complete"
      find("div.sidebar_content.primary").should_not have_link("Complete")
    end
  end

  describe "restarts a milestone" do
    it "restarts a milestone" do
      visit("#/workspaces/#{workspace.id}")
      click_link "Milestones"
      find("li", :text => "Milestone 44450").click
      find("div.sidebar_content.primary").should have_content("Milestone 44450")
      click_link "Complete"
      find("div.sidebar_content.primary").should_not have_link("Complete")
      click_link "Restart"
      find("div.sidebar_content.primary").should_not have_link("Restart")
    end
  end

  describe "deletes a milestone" do
    it "restarts a milestone" do
      visit("#/workspaces/#{workspace.id}")
      click_link "Milestones"
      find("li", :text => "Milestone 44452").click
      find("div.sidebar_content.primary").should have_content("Milestone 44452")
      click_link "Delete"
      within_modal do
        click_button "Delete"
      end
      page.should_not have_content "Milestone 44452"
    end
  end
end
