require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Workspaces" do
  before do
    login(users(:admin))
  end
  let(:workspace) { workspaces(:public) }

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
