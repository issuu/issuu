require 'spec_helper'

describe Issuu::DocumentEmbed do
  before(:each) { @empty_parameter_set = Issuu::ParameterSet.new("action") }

  let(:issuu_document_embed_hash) do
    {
        "documentEmbed"=>
            {
                "id" => "1000068",
                "dataConfigId" => "1000980/1000071",
                "documentId" => "131030110954-12df4c6d21ba49af8eb1350219b0d4ef",
                "readerStartPage" => 3,
                "width" => 320,
                "height" => 240,
                "created" => "2013-10-30T11:09:55.000Z"
            }
    }
  end

  describe "creating a new document embed object" do
    subject { Issuu::DocumentEmbed.new({:dataConfigId => "1000980/1000041", :id => "123456789"}) }

    it "should assign all the params given in the hash and make them accessible" do
      subject.dataConfigId.should == "1000980/1000041"
      subject.id.should == "123456789"
      subject.attributes.should == {:dataConfigId => "1000980/1000041", :id => "123456789"}
    end
  end

  describe "add a document embed" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
          {"rsp"=>
               {
                   "_content" => issuu_document_embed_hash,
                   "stat" => "ok"
               }
          }
      )
    end

    describe "basic add" do
      subject { Issuu::DocumentEmbed.add("131030110954-12df4c6d21ba49af8eb1350219b0d4ef", 3, 320, 240) }

      it "should return an instance of the added document embed" do
        subject.class.should == Issuu::DocumentEmbed
        subject.id.should == "1000068"
      end
    end
  end

  describe "listing document embeds" do
    before(:each) do
      Issuu::Cli.stub!(:http_get).and_return(
          {"rsp"=>
               {
                   "_content" =>
                       {
                           "result" =>
                               {
                                   "_content" => [issuu_document_embed_hash]
                               }
                       },
                   "stat" => "ok"
               }
          }
      )
    end

    describe "basic listing" do
      subject { Issuu::DocumentEmbed.list }

      it "should return an instance of the document embed" do
        subject.class.should == Array
        subject.first.id.should == "1000068"
      end
    end

    describe "listing with extra parameters" do
      it "should pass the extra parameters to the ParameterSet" do
        Issuu::ParameterSet.should_receive(:new).with(
            "issuu.document_embeds.list",
            {:documentId => "my document id"}
        ).and_return(@empty_parameter_set)
        Issuu::DocumentEmbed.list({:documentId => "my document id"})
      end
    end
  end

  describe "delete document embed" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return({
                                                  "rsp" => {
                                                      "stat" => "ok"
                                                  }
                                              })
    end

    subject { Issuu::DocumentEmbed.delete("embed_id") }

    it "should return an instance of the document embed" do
      subject == true
    end

    subject { Issuu::DocumentEmbed.delete('embed_id', {:api_key => "secret", :secret => "secret"}) }

    it "should return an instance of the document embed" do
      subject == true
    end
  end

  describe "update a document embed" do
    before(:each) do
      Issuu::Cli.stub!(:http_post).and_return(
          {"rsp"=>
               {
                   "_content" => issuu_document_embed_hash,
                   "stat" => "ok"
               }
          }
      )
      Issuu::ParameterSet.should_receive(:new).with(
          "issuu.document_embed.update",
          {:embedId => "embed_id", :documentId => "my document id", :readerStartPage => "5"}
      ).and_return(@empty_parameter_set)
    end

    subject { Issuu::DocumentEmbed.update("embed_id", {:documentId => "my document id", :readerStartPage => "5"}) }

    it "should pass the extra parameters to the ParameterSet" do
      subject.class.should == Issuu::DocumentEmbed
      subject.id.should == "1000068"
    end
  end

  describe "getting docuement embed code" do
    before(:each) do
      Issuu::Cli.stub!(:http_raw_get).and_return(
          '<div data-configid="1000974/1000068" style="width: 320px; height: 180px;" class="issuuembed"></div><script type="text/javascript" src="//e.issuu.com/embed.js" async="true"></script>'
      )
    end

    subject { Issuu::DocumentEmbed.get_html_code('my embed id') }

    it "should return an html snippit" do
      subject.should == '<div data-configid="1000974/1000068" style="width: 320px; height: 180px;" class="issuuembed"></div><script type="text/javascript" src="//e.issuu.com/embed.js" async="true"></script>'
    end
  end

end
