require 'spec_helper'

describe Issuu::Folder do
  before(:each) { @empty_parameter_set = Issuu::ParameterSet.new("action") }
  
  let(:issuu_folder_hash) do 
    {
      "folder"=>
      {
        "folderId" => "4c3ba964-60c3-4349-94d0-ff86db2d47c9", 
        "username" => "ferrogate", 
        "name" => "Cool stuff", 
        "description" => "Stuff I have collected", 
        "items" => 0, 
        "created" => "2009-07-12T19:52:15.000Z"
      }
    }
  end
  
  describe "creating a new folder object" do
    subject { Issuu::Folder.new({:name => "Magma", :description => "Rocks!"}) }
    
    it "should assign all the params given in the hash and make them accessible" do
      subject.name.should == "Magma"
      subject.description.should == "Rocks!"
      subject.attributes.should == {:name => "Magma", :description => "Rocks!"}
    end
  end
  
  describe "add a folder" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
        {"rsp"=>
          {
            "_content" => issuu_folder_hash,
            "stat" => "ok"
          }
        }
      )
    end
    
    describe "basic add" do
      subject { Issuu::Folder.add("folder_name") }

      it "should return an instance of the uploaded document" do
        subject.class.should == Issuu::Folder
        subject.name.should == "Cool stuff"
      end
    end
    
    describe "add with extra parameters" do
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
          "issuu.folder.add",
          {:folderName=>"folder_name", :description=>"some description"}
        ).and_return(@empty_parameter_set)
        Issuu::Folder.add("folder_name", {:description => "some description"})
      end
    end
  end
  
  describe "listing folders" do
    before(:each) do
      Issuu::Cli.stub!(:http_get).and_return(
        {"rsp"=>
          {
            "_content" => 
              {
                "result" => 
                  {
                    "_content" => [issuu_folder_hash]
                  }
              },
            "stat" => "ok"
          }
        }
      )
    end
    
    describe "basic listing" do
      subject { Issuu::Folder.list }

      it "should return an instance of the uploaded document" do
        subject.class.should == Array
        subject.first.name.should == "Cool stuff"
      end
    end
    
    describe "listing with extra parameters" do
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
          "issuu.folders.list",
          {:name => "my extra name"}
        ).and_return(@empty_parameter_set)
        Issuu::Folder.list({:name => "my extra name"})
      end
    end
  end
  
  describe "delete folder" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return({ 
        "rsp" => { 
          "stat" => "ok" 
        } 
      })
    end
    
    subject { Issuu::Folder.delete(["folder_id"]) }

    it "should return an instance of the uploaded document" do
      subject == true
    end
    
    subject { Issuu::Folder.delete(["bookmark_id"], {:api_key => "secret", :secret => "secret"}) }

    it "should return an instance of the uploaded document" do
      subject == true
    end
  end
  
  describe "update a folder" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
        {"rsp"=>
          {
            "_content" => issuu_folder_hash,
            "stat" => "ok"
          }
        }
      )
      Issuu::ParameterSet.should_receive(:new).with(
        "issuu.folder.update",
        {:folderId => "folder_id", :description => "New description"}
      ).and_return(@empty_parameter_set)
    end
    
    subject { Issuu::Folder.update("folder_id", {:description => "New description"}) }
    
    it "should pass the extra parameters to the ParameterSet" do
      subject.class.should == Issuu::Folder
      subject.name.should == "Cool stuff"
    end
  end
  
end