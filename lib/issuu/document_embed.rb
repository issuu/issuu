module Issuu
  class DocumentEmbed
    attr_reader :attributes

    def initialize(hash)
      @attributes = hash
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
      def add(document_id, reader_start_page, width, height, params = {})
        response = Cli.http_post(
            Issuu::API_URL,
            ParameterSet.new("issuu.document_embed.add",
                             params.merge({
                                              :documentId => document_id,
                                              :readerStartPage => reader_start_page.to_s,
                                              :width => width.to_s,
                                              :height => height.to_s
                                          })
            ).output
        )
        DocumentEmbed.new(response["rsp"]["_content"]["documentEmbed"])
      end

      def list(params={})
        response = Cli.http_get(
            Issuu::API_URL,
            ParameterSet.new("issuu.document_embeds.list", params).output
        )
        response["rsp"]["_content"]["result"]["_content"].map{|embed_hash| DocumentEmbed.new(embed_hash["documentEmbed"]) }
      end

      def update(embed_id, params={})
        response = Cli.http_post(
            Issuu::API_URL,
            ParameterSet.new("issuu.document_embed.update", params.merge({:embedId => embed_id})).output
        )
        DocumentEmbed.new(response["rsp"]["_content"]["documentEmbed"])
      end

      def delete(embed_id, params={})
        Cli.http_post(
            Issuu::API_URL,
            ParameterSet.new("issuu.document_embed.delete", params.merge({:embedId => embed_id})).output
        )
        return true
      end

      def get_html_code(embed_id, params = {})
        response = Cli.http_raw_get(
            Issuu::API_URL,
            ParameterSet.new("issuu.document_embed.get_html_code", params.merge({:embedId => embed_id })).output
        )
        return response
      end

    end
  end
end