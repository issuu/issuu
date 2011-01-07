module Issuu
  class Folder
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
      def add(name, params={})
        response = Cli.http_post(
          Issuu::API_URL,
          ParameterSet.new("issuu.folder.add", params.merge(:folderName => name)).output
        )
        Folder.new(response["rsp"]["_content"]["folder"])
      end
      
      def list(params={})        
        response = Cli.http_get(
          Issuu::API_URL, 
          ParameterSet.new("issuu.folders.list", params).output
        )
        response["rsp"]["_content"]["result"]["_content"].map{|folder_hash| Document.new(folder_hash["folder"]) }
      end
      
      def update(folder_id, params={})    
        response = Cli.http_post(
          Issuu::API_URL,
          ParameterSet.new("issuu.folder.update", params.merge(:folderId => folder_id)).output
        )
        Folder.new(response["rsp"]["_content"]["folder"])
      end
      
      def delete(folder_ids)        
        Cli.http_post(
          Issuu::API_URL,
          ParameterSet.new("issuu.folder.delete", {:folderIds => folder_ids.join(',')}).output
        )
        return true
      end
    end
  end
end