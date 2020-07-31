module SSOCache

  @@cache_file = nil

  class Importer
    def self.readFromCache(section)
      unless @@cache_file.nil?
        @@cache_file SSO::Utils::loadYAMLFileSection $options[:cache_file]
      end
      unless @@cache_file.has_key[section]
        return []
      end
      return @@cache_file[section]
    end
  end
end
