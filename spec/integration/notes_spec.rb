require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Notes" do
  before do
    login(users(:admin))
  end
  
  describe "creating a note on a GPDB data source" do
    it "contains the note" do
      data_source = data_sources(:default)
      visit("#/data_sources")
      within ".data_source ul" do
        first("li", :text => data_source.name).click
      end
      click_link "Add a note"

      within_modal do
        set_cleditor_value("body", "Note on the data source")
        click_button "Add Note"
      end

      data_source.events.last.body.should == "Note on the data source"
    end
  end

  describe "creating a note on a workspace" do
    it "creates the note" do
      workspace = workspaces(:public_with_no_collaborators)
      visit("#/workspaces/#{workspace.id}")
      click_link "Add a note"

      within_modal do
        set_cleditor_value("body", "Note on the workspace")
        click_button "Add Note"
      end

      workspace.reload.events.last.body.should == "Note on the workspace"
    end
  end

  describe "creating a note on a hadoop data source" do
    it "creates the note" do
      hdfs_data_source = hdfs_data_sources(:hadoop)
      visit("#/data_sources")
      within ".hdfs_data_source ul" do
        find("li", :text => hdfs_data_source.name).click
      end
      click_link "Add a note"

      within_modal do
        set_cleditor_value("body", "Note on the hadoop data source")
        click_button "Add Note"
      end

      hdfs_data_source.events.last.body.should == "Note on the hadoop data source"
    end
  end

  describe "creating a note on a workfile" do
    it "creates the note" do
      workfile = workfiles(:no_collaborators_public)
      workspace = workfile.workspace
      visit("#/workspaces/#{workspace.id}/workfiles")
      within ".selectable.list" do
        find("li", :text => workfile.file_name).click
      end
      click_link "Add a note"

      within_modal do
        set_cleditor_value("body", "Note on a workfile")
        click_button "Add Note"
      end

      workfile.events.last.body.should == "Note on a workfile"
    end
  end

  describe "creating a note with an attachment" do
    it "creates the note" do
      Tempfile.open "test_upload" do |tempfile|
        workfile = workfiles(:no_collaborators_public)
        workspace = workfile.workspace
        visit("#/workspaces/#{workspace.id}/workfiles")
        within ".selectable.list" do
          find("li", :text => workfile.file_name).click
        end
        click_link "Add a note"

        within_modal do
          set_cleditor_value("body", "Note on a workfile")
          click_on "Show options"
          attach_file "contents", "file://" + tempfile.path
          click_button "Add Note"
        end

        workfile.events.last.body.should == "Note on a workfile"
        page.should have_text(File.basename(tempfile.path))
      end
    end
  end

  describe "editing notes" do
    it "edits note" do
      visit("#/workspaces/")
      click_button "Create Workspace"
      within_modal do
        fill_in 'name', :with => "note-editing"
        click_button "Create Workspace"
      end
      click_link "Dismiss the workspace quick start guide"
      page.should have_content('All Activity')
      click_link "Add a note"
      within_modal do
        set_cleditor_value("body", "this will edit a note")
        click_button "Add Note"
      end
      page.should have_content("this will edit a note")
      find("li", :text => "this will edit a note").click_link "Edit"
      within_modal do
        set_cleditor_value("body", "edited note")
        click_button "Save Changes"
      end
      page.should have_content("edited note")
      page.should_not have_content("this will edit a note")
    end
  end

  describe "deleting a note" do
    it "deletes a note" do
      visit("#/workspaces/")
      click_button "Create Workspace"
      within_modal do
        fill_in 'name', :with => "note-deletion"
        click_button "Create Workspace"
      end
      click_link "Dismiss the workspace quick start guide"
      page.should have_content('All Activity')
      click_link "Add a note"
      within_modal do
        set_cleditor_value("body", "this will delete a note")
        click_button "Add Note"
      end
      page.should have_content("this will delete a note")
      find("li", :text => "this will delete a note").click_link "Delete"
      within_modal do
        click_button "Delete Note"
      end
      page.should_not have_content("this will delete a note")
    end
  end
end

