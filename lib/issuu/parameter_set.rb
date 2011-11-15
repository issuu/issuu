module Issuu
  class ParameterSet
    def initialize(action, extra_params={})
      extra_params = HashWithIndifferentAccess.new(extra_params)
      @api_key = extra_params.delete(:api_key) || Issuu.api_key
      @secret = extra_params.delete(:secret) || Issuu.secret
      @params = extra_params.update({
        :action => action,
        :apiKey => @api_key,
        :format => "json"
      }).hash_select{ |key, value| !value.nil? }
    end
    
    def generate_signature
      string_to_sign = "#{@secret}#{@params.sort_by {|k| k.to_s }.flatten.join}"
      Digest::MD5.hexdigest(string_to_sign)
    end
    
    def output
      @params.merge({:signature => generate_signature})
    end
  end
end