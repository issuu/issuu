require 'spec_helper'

describe Issuu::IssuuExceptionManager do
  
  describe "Invalid field exception" do
    it "should raise an exception with the invalid field" do
      manager = Issuu::IssuuExceptionManager.new({'code'=>'201', 'message' => 'Invalid field format', 'field' => 'apiKey'})
      expect {manager.raise_error}.should raise_error(Issuu::IssuuException, '#201 Invalid field format: \'apiKey\'')
    end
  end

  describe "Authentication exception" do
    it "should raise an exception with the invalid field" do
      manager = Issuu::IssuuExceptionManager.new({'code'=>'009', 'message' => 'Authentication required'})
      expect {manager.raise_error}.should raise_error(Issuu::IssuuException, '#009 Authentication required')
    end
  end
end