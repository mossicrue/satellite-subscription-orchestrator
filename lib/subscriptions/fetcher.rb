module SSOSubscriptions
  class Fetcher

    @@parsed_subscriptions = []

    def self.parseSubscriptions
      SSO::Utils::putsStandard "Subscription parsing started. It may take sometime."
      self.checkCache
      unless @@parsed_subscriptions.count > 0
        self.readAllRules
      end
      SSO::Utils::putsStandard "Subscription successfully parsed"
    end

    def self.checkCache
      unless $options[:use_cache]
        @@parsed_subscriptions = []
      end
      SSO::Utils::putsStandard "  Subscriptions parsed from cache"
      @@parsed_subscriptions = SSOCache::Importer::readFromCache :subs
    end

    def self.readAllRules
      subscription_entries = SSO::Utils::loadYAMLFileSection $options[:config_file], :subs
      sub_entries = subscription_entries.count
      subscription_entries.each_with_index do |sub_entry, entry_index|
        SSO::Utils::putsStandard "  Start parsing subscription entry #{entry_index}/#{sub_entries}"
        self.parseSubEntry sub_entry
      end
    end

    def self.parseSubEntry(sub_entry)
      unless sub_entry.is_a? Hash
        SSO::Utils::putsStandard "    Subscription entry has not valid data, or is empty. Skipping"
        return
      end
    end
  end
end
