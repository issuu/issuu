require 'spec_helper'

describe Issuu::ParameterSet do
  describe "with a hash as parameter" do
    it "should delete the api_key from the options" do
      input = {"api_key" => 'secret', "secret" => "secret"}
      Issuu::ParameterSet.new("issuu.document.update", input).output.should eql({
        "action"=>"issuu.document.update",
        "apiKey"=>"secret",
        "format"=>"json",
        :signature=>"942b5a7f777c638a5e03b9dcc31ea99e"
      })
    end
    
    it "should delete the empty values from the options" do
      input = {"api_key" => 'secret', "secret" => "secret", :access => nil}
      Issuu::ParameterSet.new("issuu.document.update", input).output.should eql({
        "action"=>"issuu.document.update",
        "apiKey"=>"secret",
        "format"=>"json",
        :signature=>"942b5a7f777c638a5e03b9dcc31ea99e"
      })
    end
  end
  
  describe "with a HashWithIndifferentAccessAsParameter" do
    it "should delete the api_key from the options" do
      input = HashWithIndifferentAccess.new({"api_key" => 'secret', "secret" => "secret", "ratingsAllowed" => true})
      Issuu::ParameterSet.new("issuu.document.update", input).output.should eql({
        "ratingsAllowed"=>true,
        "action"=>"issuu.document.update",
        "apiKey"=>"secret",
        "format"=>"json",
        :signature=>"7588956a5aaa963ebc24d94ba7f852e6"
      })
    end
  end
end