require 'spec_helper'

describe Issuu::Document do
  before(:each) { @empty_parameter_set = Issuu::ParameterSet.new("action") }
  
  let(:issuu_document_hash) do 
    {
      "document"=>
      {
        "ep"=>1245759831,
        "pageCount"=>0,
        "documentId"=>"090623122351-f691a27cfd744b80b25a2c8f5a51d596",
        "name"=>"racing",
        "category"=>"012000",
        "title"=>"Race cars",
        "username"=>"magma",
        "tags"=>["cars", "le man", "racing"],
        "origin"=>"singleupload",
        "type"=>"009000",
        "description"=>"Race cars of Le Man 2009",
        "access"=>"public",
        "folders"=>["3935f331-5d5b-4694-86ce-6f26c6dee809"],
        "state"=>"P"
      }
    }
  end
  
  describe "creating a new document object" do
    subject { Issuu::Document.new({:name => "Magma", :description => "Rocks!"}) }
    
    it "should assign all the params given in the hash and make them accessible" do
      subject.name.should == "Magma"
      subject.description.should == "Rocks!"
      subject.attributes.should == {:name => "Magma", :description => "Rocks!"}
    end
  end
  
  describe "uploading a file" do
    before(:each) do
      Issuu::Cli.stub!(:http_multipart_post).and_return(
        {"rsp"=>
          {
            "_content" => issuu_document_hash,
            "stat" => "ok"
          }
        }
      )
      UploadIO.stub!(:new).and_return("a file")
    end
    
    describe "basic upload" do
      subject { Issuu::Document.upload("a/file/path", "file/type") }

      it "should return an instance of the uploaded document" do
        subject.class.should == Issuu::Document
        subject.title.should == "Race cars"
      end
    end
    
    describe "upload with extra parameters" do      
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
          "issuu.document.upload",
          {:name => "my extra name"}
        ).and_return(@empty_parameter_set)
        Issuu::Document.upload("a/file/path", "file/type", {:name => "my extra name"})
      end
    end
  end
  
  describe "uploading a url" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
        {"rsp"=>
          {
            "_content" => issuu_document_hash,
            "stat" => "ok"
          }
        }
      )
    end
    
    describe "basic url upload" do
      subject { Issuu::Document.url_upload("a/file/url") }

      it "should return an instance of the uploaded document" do
        subject.class.should == Issuu::Document
        subject.title.should == "Race cars"
      end
    end
    
    describe "url upload with extra parameters" do
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
          "issuu.document.url_upload",
          {:slurpUrl=>"a/file/url", :name => "my extra name"}
        ).and_return(@empty_parameter_set)
        Issuu::Document.url_upload("a/file/url", {:name => "my extra name"})
      end
    end
  end
  
  describe "listing documents" do
    before(:each) do
      Issuu::Cli.stub!(:http_get).and_return(
        {"rsp"=>
          {
            "_content" => 
              {
                "result" => 
                  {
                    "_content" => [issuu_document_hash]
                  }
              },
            "stat" => "ok"
          }
        }
      )
    end
    
    describe "basic listing" do
      subject { Issuu::Document.list }

      it "should return an instance of the uploaded document" do
        subject.class.should == Array
        subject.first.title.should == "Race cars"
      end
    end
    
    describe "listing with extra parameters" do
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
          "issuu.documents.list",
          {:name => "my extra name"}
        ).and_return(@empty_parameter_set)
        Issuu::Document.list({:name => "my extra name"})
      end
    end
  end
  
  describe "delete document" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return({ 
        "rsp" => { 
          "stat" => "ok" 
        } 
      })
    end
    
    subject { Issuu::Document.delete(["document_id"]) }

    it "should return an instance of the uploaded document" do
      subject == true
    end
    
    subject { Issuu::Document.delete(["bookmark_id"], {:api_key => "secret", :secret => "secret"}) }

    it "should return an instance of the uploaded document" do
      subject == true
    end
  end
  
  describe "update a document" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
        {"rsp"=>
          {
            "_content" => issuu_document_hash,
            "stat" => "ok"
          }
        }
      )
      Issuu::ParameterSet.should_receive(:new).with(
        "issuu.document.update",
        {:name => "document_name", :publishDate => "1997-07-16"}
      ).and_return(@empty_parameter_set)
    end
    
    subject { Issuu::Document.update("document_name", {:publishDate => "1997-07-16"}) }
    
    it "should pass the extra parameters to the ParameterSet" do
      subject.class.should == Issuu::Document
      subject.title.should == "Race cars"
    end
  end
  
  describe "signing a request" do

    subject { Issuu::ParameterSet.new 'issuu.documents.list',
      :api_key => 'qyy6ls1qv15uh9xwwlvk853u2uvpfka7',
      :secret => '13e3an36eaxjy8nenuepab05yc7j7w5g',
      :access => 'public',
      :responseParams => 'title,description' }

    it "should generate a correct signature" do
      subject.generate_signature.should == '7431d31140cf412ab5caa73586d6324a'
    end
  end

  describe "basic searching" do
    subject { Issuu::Document.search(:q => "test") }
    it "should return a list of documents matching the search term" do
      subject.class.should == Hash
      subject.should have_key "numFound"
      subject.should have_key "docs"
      subject["docs"].class.should == Array
    end
  end

  describe "search and return array of Issuu::Documents" do
    subject { Issuu::Document.search({:q => "test"}, {:should_convert_to_v1_doc_style => true}) }
    it "should return a list of documents matching the search term" do
      subject.class.should == Array
      subject.first.class.should == Issuu::Document
    end
  end

  #this test could break since it relies on a specific document
  describe "Basic page searching" do
    subject { Issuu::Document.search({:q => "map", :documentId => "130703234720-22e380f63a33451e8116ce86a3abcbfe"}, {:page => true}) }
    it "should return a list of pages referencing map in the document" do
      subject.class.should == Hash
      subject["docs"].first.should have_key "pageId"
      subject["docs"].first["pageId"].should == 3
    end
  end
  
end