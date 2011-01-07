module Issuu
  class Bookmark
    def initialize(hash)
      hash.each do |key, value|
        metaclass.send :attr_accessor, key
        instance_variable_set("@#{key}", value)
      end
    end
    
    def metaclass
      class << self
        self
      end
    end
    
    class << self
      def add(name, document_user_name, params={})
        response = Cli.http_post(
          Issuu::API_URL,
          ParameterSet.new("issuu.bookmark.add", params.merge({:name => name, :documentUsername => document_user_name})).output
        )
        Bookmark.new(response["rsp"]["_content"]["bookmark"])
      end
      
      def list(params={})        
        response = Cli.http_get(
          Issuu::API_URL,
          ParameterSet.new("issuu.bookmarks.list", params).output
        )
        response["rsp"]["_content"]["result"]["_content"].map{|bookmark_hash| Document.new(bookmark_hash["bookmark"]) }
      end
      
      def update(bookmark_id, params={})        
        response = Cli.http_post(
          Issuu::API_URL,
          ParameterSet.new("issuu.bookmark.update", params.merge({:bookmarkId => bookmark_id})).output
        )
        Bookmark.new(response["rsp"]["_content"]["bookmark"])
      end
      
      def delete(bookmark_ids)        
        Cli.http_post(
          Issuu::API_URL,
          ParameterSet.new("issuu.bookmark.delete", {:bookmarkIds => bookmark_ids.join(',')}).output
        )
        return true
      end
    end
  end
end