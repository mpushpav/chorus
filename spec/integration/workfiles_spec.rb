require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Workfiles" do
  let(:workspace) { workspaces(:public) }
  let(:user) { users(:admin) }

  describe "add a workfile" do
    it "uploads a workfile from the local system" do
      login(user)
      visit("#/workspaces/#{workspace.id}")

      click_link "Work Files"
      click_button("Upload File")
      within_modal do
        attach_file("workfile[versions_attributes][0][contents]", File.join(File.dirname(__FILE__), '../fixtures/some.txt'))
        click_button("Upload File")
      end
      find('.sub_nav a', :text => "Work Files").click
      page.should have_content "some.txt"
      workspace.workfiles.find_by_file_name("some.txt").should_not be_nil
    end
  end

  describe "Deleting workfiles" do
    let(:workfile) { workfiles(:'sql.sql') }

    it "deletes an uploaded file from the show page" do
      login(user)
      visit("#/workspaces/#{workspace.id}")

      click_link "Work Files"
      click_link workfile.file_name
      click_link "Delete work file"

      within_modal do
        click_button "Delete work file"
      end
      page.should_not have_content(workfile.file_name)
      Workfile.find_by_id(workfile.id).should be_nil
    end

    it "deletes a work file created on chorus" do
      login(user)
      visit("#/workspaces/#{workspace.id}")
      click_link "Work Files"
      click_button "Create"
      click_link "SQL File"
      fill_in 'fileName', :with => "sample"
      click_button "Add SQL File"
      page.should have_content("sample.sql")
      click_link "Delete work file"
      within_modal do
        click_button "Delete work file"
      end
      workspace.workfiles.find_by_file_name("sample.sql").should be_nil
    end
  end

  describe "workfiles list page" do
    let(:workfile_first_by_date) { workspace.workfiles.order(:user_modified_at).last }
    let(:workfile_last_by_date) { workspace.workfiles.order(:user_modified_at).first }

    describe "Lists the work files" do
      before(:each) do
        login(user)
        visit("#/workspaces/#{workspace.id}/workfiles")
      end

      it "Lists the work files by updated date when selected" do
        wait_for_page_load
        find('a', :text => "Alphabetically", :visible => true).click
        find('a', :text => "By Date", :visible => true).click
        find('.workfile_sidebar .fileName').should have_content(workfile_first_by_date.file_name)
        workfiles = page.all(".workfile_item")
        workfiles.first.text.should include workfile_first_by_date.file_name
        workfiles.last.text.should include workfile_last_by_date.file_name
      end
    end
  end

  describe "editing a workfile", :greenplum_integration do
    let(:workspace) { workspaces(:real) }
    let(:user) { users(:admin) }
    let(:file) { File.open(Rails.root.join('spec', 'fixtures', 'workfile.sql')) }
    let(:workfile) { FactoryGirl.create :chorus_workfile, :workspace => workspace, :file_name => 'sqley.sql', :execution_schema => workspace.sandbox, :owner => user }

    before do
      FactoryGirl.create :workfile_version, :workfile => workfile, :owner => user, :modifier => user, :contents => file
      login(user)
      visit("#/workspaces/#{workspace.id}/workfiles/#{workfile.id}")
    end

    def type_workfile_contents(text)
      page.execute_script "chorus.page.mainContent.content.textContent.editor.setValue('#{text}')"
    end

    def get_workfile_contents
      page.execute_script "return chorus.page.mainContent.content.textContent.editor.getValue()"
    end

    describe "changing the schema" do
      it "should retain any pre-existing edits" do
        page.should have_css ".CodeMirror-lines"
        type_workfile_contents "fooey"
        click_link "Change"
        within_modal do
          within ".schema .select_container" do
            page.should have_content(workspace.sandbox.name)
          end
          click_button "Save Search Path"
        end
        get_workfile_contents.should == "fooey"
      end
    end

    describe "if you don't have a valid data source account for the schema" do
      let(:user) { users(:restricted_user) }
      it "should display an 'add credentials' link in the sidebar" do
        page.find('.data_tab').should have_text("add your credentials")
      end
    end
  end

  describe "Version control on workfiles" do

    def type_workfile_contents(text)
      page.execute_script "chorus.page.mainContent.content.textContent.editor.setValue('#{text}')"
    end

    def get_workfile_contents
      page.execute_script "return chorus.page.mainContent.content.textContent.editor.getValue()"
    end

    it "can create new versions of the work file" do
      login(user)
      visit("#/workspaces/#{workspace.id}")
      click_link "Work Files"
      click_button "Create"
      click_link "SQL File"
      fill_in 'fileName', :with => "sample"
      click_button "Add SQL File"
      page.should have_content("sample.sql")
      page.should have_css ".CodeMirror-lines"
      type_workfile_contents "this is versioning 2"
      click_button "Save As"
      find("a", :text => "Save as new version").click
      within_modal do
        set_cleditor_value("commitMessage", "testing file versioning no.2")
        click_button "Save New Version"
      end
      type_workfile_contents "this is versioning 3"
      click_button "Save As"
      find("a", :text => "Save as new version").click
      within_modal do
        set_cleditor_value("commitMessage", "testing file versioning no.3")
        click_button "Save New Version"
      end

      find("a", :text => "Version 3").click
      find("a", :text => "Version 2").click
      page.should have_content "this is versioning 2"

      find("a", :text => "Version 2").click
      find("a", :text => "Version 3").click
      page.should have_content "this is versioning 3"
    end

    it  "replaces the current version of the file" do
      login(user)
      visit("#/workspaces/#{workspace.id}")
      click_link "Work Files"
      click_button "Create"
      click_link "SQL File"
      fill_in 'fileName', :with => "sample"
      click_button "Add SQL File"
      page.should have_content("sample.sql")
      page.should have_css ".CodeMirror-lines"
      type_workfile_contents "this is file replacement test"
      click_button "Save As"
      find("a", :text => "Replace current version").click
      get_workfile_contents == "this is file replacement test"
      find("a", :text => "Version 1").click
      page.should_not have_content "Version 2"
    end
  end

  describe "Rename a workfile" do

    it "renames a workfile" do
      login(user)
      visit("#/workspaces/#{workspace.id}")
      click_link "Work Files"
      click_button "Create"
      click_link "SQL File"
      fill_in 'fileName', :with => "sample"
      click_button "Add SQL File"
      page.should have_content("sample.sql")
      click_link "Rename"
      within_modal do
        fill_in 'fileName', :with => "rename-sample"
        click_button "Rename"
      end
      page.should have_content ("rename-sample.sql")
      click_link "Summary"
      click_link "Work Files"
      workspace.workfiles.find_by_file_name("rename-sample.sql").should_not be_nil
    end
  end

  describe "copies a workfile to another workspace" do

    it "copies the workfile" do

      login(user)
      visit("#/workspaces/")
      click_button "Create Workspace"
      within_modal do
        fill_in 'name', :with => "abc"
        click_button "Create Workspace"
      end
      visit("#/workspaces/#{workspace.id}")
      click_link "Work Files"
      click_button "Create"
      click_link "SQL File"
      fill_in 'fileName', :with => "sample"
      click_button "Add SQL File"
      page.should have_content("sample.sql")
      click_link "Copy latest version"
      find("li", :text => "abc").click
      click_button "Copy File"

      visit("#/workspaces/")
      workspace_name ="abc"
      within ".main_content_list" do
        find("a", :text => /^#{workspace_name}$/).click()
      end
      click_link "Work Files"
      page.should have_content "sample.sql"
    end
  end
end
