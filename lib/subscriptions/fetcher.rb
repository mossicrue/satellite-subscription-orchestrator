module Subscriptions
  class Fetcher

    @@parsed_subscriptions = []

    def self.parseSubscriptions
      self.checkForCache
      unless @@parsed_subscriptions.count > 0
        # parsing if cache not generate records
      end
    end

    def self.checkForCache
      unless $options[:use_cache]
        return []
      end

    end

    def self.readAllRules
      subscription_entries = SSO::Utils::loadYAMLFileSection $options[:config_file], :subs
      subscription_entries.each_with_index do |sub_entry, entry_index|

      end
    end

    def self.parseSubEntry

    end
  end
end
