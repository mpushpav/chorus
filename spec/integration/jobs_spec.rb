require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Jobs" do
  before do
    login(users(:admin))
  end

  it "creates a job on a workspace" do
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "creating-jobs"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    Workspace.find_by_name("creating-jobs").should_not be_nil

    click_link "Jobs"
    click_button "Create"
    within_modal do
      find('.name').set("job-test")
      choose "onDemand"
      click_button "Create"
    end
    page_title_should_be("job-test")
    click_link "Summary"
    click_link "Jobs"
    page.should have_content("job-test")
  end

  it "deletes a job" do
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "deleting-jobs"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    Workspace.find_by_name("deleting-jobs").should_not be_nil

    click_link "Jobs"
    click_button "Create"
    within_modal do
      find('.name').set("delete-job")
      choose "onDemand"
      click_button "Create"
    end
    page_title_should_be("delete-job")
    click_link "Summary"
    click_link "Jobs"
    find("li", :text => "delete-job").click
    find("div.sidebar_content.primary").should have_content("delete-job")
    click_link "Delete"
    within_modal do
      click_button "Delete Job"
    end
    click_link "Summary"
    click_link "Jobs"
    page.should_not have_content("delete-job")
  end

  it "creates a job on schedule" do
    visit('#/workspaces')
    click_button "Create Workspace"
    within_modal do
      fill_in 'name', :with => "job-scheduler"
      click_button "Create Workspace"
    end
    click_link "Dismiss the workspace quick start guide"
    page.should have_content('All Activity')
    Workspace.find_by_name("job-scheduler").should_not be_nil

    click_link "Jobs"
    click_button "Create"
    within_modal do
      find('.name').set("new_job")
      choose "onSchedule"
      find(".interval_options input.interval_value").set("13")
      check "end_date_enabled"
      find(".end_date_widget .year").set("2017")
      click_button "Create"
    end
    page_title_should_be("new_job")
    click_button "Enable"
    click_link "Summary"
    click_link "Jobs"
    page.should have_content("new_job")
  end
end