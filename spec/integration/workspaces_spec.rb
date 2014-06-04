require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Workspaces" do
  before do
    login(users(:admin))
  end

  let(:workspace) { workspaces(:public) }

  describe "Create workspaces" do
    it "creates a public workspace" do
      visit('#/workspaces')
      click_button "Create Workspace"
      within_modal do
        fill_in 'name', :with => "New Workspace"
        click_button "Create Workspace"
      end
      click_link "Dismiss the workspace quick start guide"
      page.should have_content('All Activity')
      Workspace.find_by_name("New Workspace").should_not be_nil
    end

  end

  describe "Edit a workspace" do
    it "uploads an image for a workspace" do
      visit("#/workspaces/#{workspace.id}")
      click_link "Edit Workspace"
      attach_file("image_upload_input", File.join(File.dirname(__FILE__), '../fixtures/User.png'))
      click_button "Save Changes"
      page.should have_selector(".breadcrumb:contains('#{workspace.name}')")
      workspace.reload.image.original_filename.should == 'User.png'
    end

    context "with more than 24 members" do
      before do
        members = 25.times.map { |n| FactoryGirl.create(:user, username: "uSeR#{n}") }
        workspace.members << members
        workspace.save
      end

      describe "the 'change owner' drop-down menu" do
        before do
          visit("#/workspaces/#{workspace.id}")
          click_link "Edit Workspace"
        end

        it "displays all members" do
          within('#selectowner') do
            page.should have_css('option', count: workspace.members.count)
          end
        end
      end
    end
  end

  describe "Delete a workspace" do
    it "deletes the workspace" do
      stub(Alpine::API).delete_work_flow(anything)
      visit("#/workspaces/#{workspace.id}")
      wait_for_page_load
      click_link "Delete this Workspace"
      click_button "Delete Workspace"

      page.should have_content("deleted workspace #{workspace.name}")
      visit('/#/workspaces')

      wait_for_page_load
      Workspace.find_by_id(workspace.id).should be_nil
    end
  end

  describe "Archive a worksapce" do
    it "archives a workspace" do
      visit("#/workspaces/")
      click_button "Create Workspace"
      within_modal do
        fill_in 'name', :with => "abc"
        click_button "Create Workspace"
      end
      click_link "Dismiss the workspace quick start guide"
      page.should have_content('All Activity')
      click_link "Edit Workspace"
      within_modal do
        choose "workspace_archived"
        click_button "Save Changes"
      end
      page.should_not have_content("Add a note")
      page.should_not have_content("Add an insight")
      visit("#/workspaces/")
      page.should_not have_content("abc")
    end
  end

  describe "Edit the description on the workspace" do
    it "adds description to the workspace" do
      visit("#/workspaces/")
      click_button "Create Workspace"
      within_modal do
        fill_in 'name', :with => "abc"
        click_button "Create Workspace"
      end
      click_link "Dismiss the workspace quick start guide"
      page.should have_content('All Activity')
      click_link "Edit Workspace"
      within_modal do
        set_cleditor_value("summary", "This is adding a description to the workspace")
        click_button "Save Changes"
      end
      page.should have_content("This is adding a description to the workspace")
      click_link "Edit Workspace"
      within_modal do
        set_cleditor_value("summary", "This is edited description")
        click_button "Save Changes"
      end
      page.should have_content("This is edited description")

    end
  end

end