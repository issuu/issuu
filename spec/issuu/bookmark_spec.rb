require 'spec_helper'

describe Issuu::Bookmark do
  before(:each) { @empty_parameter_set = Issuu::ParameterSet.new("action") }
  
  let(:issuu_bookmark_hash) do 
    {
      "bookmark"=>
      {
        "bookmarkId" => "11b27cd5-ecdc-4c39-b818-8f3c8eca443c", 
        "username" => "travelmagazine",
        "documentId" => "081024182109-9280632f2866416d97634cdccc66715d", 
        "documentUsername" => "publination", 
        "name" => "wildswim", 
        "title" => "Wild Swim: The best outdoor swims across Britain", 
        "description" => "Wild Swim by Kate Rew is the definitive guide to over 300 beautiful outdoor swims in rivers, lakes, tidal pools, the sea and lidos across Britain. By the founder of the Outdoor Swimming Society.", 
        "page" => 1, 
        "created" => "2009-06-22T07:54:17.000Z", 
        "folders" => [ 
            "52ab7b36-946d-45b2-a446-f95e84b2682e" 
        ]
      }
    }
  end
  
  describe "creating a new bookmark object" do
    subject { Issuu::Bookmark.new({:name => "Magma", :description => "Rocks!"}) }
    
    it "should assign all the params given in the hash and make them accessible" do
      subject.name.should == "Magma"
      subject.description.should == "Rocks!"
      subject.attributes.should == {:name => "Magma", :description => "Rocks!"}
    end
  end
  
  describe "add a bookmark" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
        {"rsp"=>
          {
            "_content" => issuu_bookmark_hash,
            "stat" => "ok"
          }
        }
      )
    end
    
    describe "basic add" do
      subject { Issuu::Bookmark.add("filename", "username") }

      it "should return an instance of the uploaded document" do
        subject.class.should == Issuu::Bookmark
        subject.title.should == "Wild Swim: The best outdoor swims across Britain"
      end
    end
    
    describe "add with extra parameters" do
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
          "issuu.bookmark.add",
          {:name=>"filename", :documentUsername=>"username"}
        ).and_return(@empty_parameter_set)
        Issuu::Bookmark.add("filename", "username", {:name => "my extra name"})
      end
    end
  end
  
  describe "listing bookmarks" do
    before(:each) do
      Issuu::Cli.stub!(:http_get).and_return(
        {"rsp"=>
          {
            "_content" => 
              {
                "result" => 
                  {
                    "_content" => [issuu_bookmark_hash]
                  }
              },
            "stat" => "ok"
          }
        }
      )
    end
    
    describe "basic listing" do
      subject { Issuu::Bookmark.list }

      it "should return an instance of the uploaded document" do
        subject.class.should == Array
        subject.first.title.should == "Wild Swim: The best outdoor swims across Britain"
      end
    end
    
    describe "listing with extra parameters" do
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
          "issuu.bookmarks.list",
          {:name => "my extra name"}
        ).and_return(@empty_parameter_set)
        Issuu::Bookmark.list({:name => "my extra name"})
      end
    end
  end
  
  describe "delete bookmark" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return({ 
        "rsp" => { 
          "stat" => "ok" 
        } 
      })
    end
    
    subject { Issuu::Bookmark.delete(["bookmark_id"]) }

    it "should return an instance of the uploaded document" do
      subject == true
    end
    
    subject { Issuu::Bookmark.delete(["bookmark_id"], {:api_key => "secret", :secret => "secret"}) }

    it "should return an instance of the uploaded document" do
      subject == true
    end
  end
  
  describe "update a bookmark" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
        {"rsp"=>
          {
            "_content" => issuu_bookmark_hash,
            "stat" => "ok"
          }
        }
      )
      Issuu::ParameterSet.should_receive(:new).with(
        "issuu.bookmark.update",
        {:bookmarkId => "bookmark_id", :description => "New description"}
      ).and_return(@empty_parameter_set)
    end
    
    subject { Issuu::Bookmark.update("bookmark_id", {:description => "New description"}) }
    
    it "should pass the extra parameters to the ParameterSet" do
      subject.class.should == Issuu::Bookmark
      subject.title.should == "Wild Swim: The best outdoor swims across Britain"
    end
  end
  
end