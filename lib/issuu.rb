require "net/http"
require 'net/http/post/multipart'
require 'digest/md5'
require 'uri'
require 'cgi'
require 'active_support'
require 'active_support/hash_with_indifferent_access'

module Issuu
  API_URL = URI.parse('http://api.issuu.com/1_0')
  API_UPLOAD_URL = URI.parse('http://upload.issuu.com/1_0')
  API_SEARCH_URL = 'http://search.issuu.com/api/2_0/'
  
  class << self
    attr_accessor :api_key, :secret
    
    # In your initializer:
    # Issuu.configure do |c|
    #   c.api_key   = ENV['ISSUU_API_KEY']
    #   c.secret   = ENV['ISSUU_SECRET']
    # end
    #
    def configure
      yield self
    end
  end


  
end

Dir[File.dirname(__FILE__) +"/issuu/*.rb"].each {|file| require file }
require File.dirname(__FILE__) + '/hash.rb'