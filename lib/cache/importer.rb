module SSOCache
  class Importer

    @@cache_file = nil

    # function that read a section from the cache_file
    def self.readFromCache(section)
      # load cache_file only one (does it works like a singleton? Have to test)
      unless @@cache_file.nil?
        @@cache_file = SSO::Utils::loadYAMLFile $options[:cache_file]
      end
      # if section in cache isn't present, don't exit and return empty data
      unless @@cache_file.has_key[section]
        return []
      end
      # if sections present return it
      return @@cache_file[section]
    end
  end
end
