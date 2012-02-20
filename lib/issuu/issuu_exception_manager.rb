module Issuu
  class IssuuExceptionManager
    def initialize(params)
      @message = "##{params["code"]} #{params["message"]}"
      case params["code"]
      when "200","201" then
        @message << ": '#{params["field"]}'"
      end
    end
    
    def raise_error
      raise IssuuException, @message
    end
  end
  
  class IssuuException < StandardError
  end
end