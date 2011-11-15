class Hash
  # in Ruby < 1.9 select returns an array not a hash...
  def hash_select(&block)
    inject({}) do |selected_hash, param|
      key, value = param
      selected_hash[key] = value if block.call(key, value)
      selected_hash
    end
  end
end