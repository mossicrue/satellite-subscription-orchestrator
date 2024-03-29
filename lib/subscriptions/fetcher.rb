module SSOSubscriptions
  class Fetcher

    @parsed_subscriptions = []

    # main function to be called for parse all the subscriptions to be searched
    def self.parseSubscriptions
      SSO::Utils::putsStandard "Subscription parsing started. It may take sometime."
      # check if cache enable and subs present
      self.checkCache
      # if cache is empty search them from Satellite
      unless @parsed_subscriptions.count > 0
        self.readAllRules
      end
      SSO::Utils::putsStandard "Subscription successfully parsed"
    end

    # function that check if cache is present and has :subs
    def self.checkCache
      unless $options[:use_cache]
        @parsed_subscriptions = []
        return
      end
      SSO::Utils::putsStandard "  Subscriptions parsed from cache"
      @parsed_subscriptions = SSOCache::Importer::readFromCache :subs
    end

    # function that read all subscriptions rules present in :subs
    def self.readAllRules
      # load all subscription_entries from configuration file section :subs
      subscription_entries = SSO::Utils::loadYAMLFileSection $options[:config_file], :subs
      sub_entries = subscription_entries.count
      # iterate all the subscription entries to parse it
      subscription_entries.each_with_index do |sub_entry, entry_index|
        SSO::Utils::putsNewLine
        SSO::Utils::putsStandard "  Start parsing subscription entry #{entry_index + 1}/#{sub_entries}"
        # parse a single sub entry
        self.parseSubEntry sub_entry
      end
    end

    # function that parse a single sub entry
    def self.parseSubEntry(sub_entry)
      # return if sub_entry is invalid (or empty)
      return if self.invalidEntry sub_entry
      # desired product (different type of subscription) to attach are under "sub" hash of configuration file
      desired_sub_hash = sub_entry['sub']
      # iterate on all the desired product
      desired_sub_hash.each do |product, desired_product_sub|
        SSO::Utils::putsStandard "    Searching subscription for product #{product}"
        desired_product_sub.each do |subscription_item|
          SSO::Utils::putsVerbose "      Parsing Subscription for '#{subscription_item}'"
          # create the search options string to pass on api call function
          search_options = SSO::Utils::createSearch subscription_item
          # fetch all the subscriptions available for the hosts
          parse_result = SSOAPI::Handler::fetchAllResults(:subscriptions, :index, {:search => search_options, :available_for => "host"})
          if parse_result.empty?
            SSO::Utils::putsVerbose "        Parsing results for '#{subscription_item}' is empty, not adding subscription"
          end
        end
      end
    end

    # check if subscription entry is invalid or not
    def self.invalidEntry(sub_entry)
      # check if a subscription entry is invalid
      unless sub_entry.is_a? Hash
        SSO::Utils::putsStandard "    Subscription entry has not valid data, or is empty. Skipping."
        return true
      end
      # check if the desired subscription present in a subscription entry has sub to be parsed
      unless sub_entry.has_key? 'sub'
        SSO::Utils::putsStandard "    No subscriptions data in current Subscription entry. Skipping."
        return true
      end
      # check if subscriptions to be parsed are in valid format
      unless sub_entry['sub'].is_a? Hash
        SSO::Utils::putsStandard "    Current Subscription entry has not valid subscription data. Skipping."
        return true
      end
      # in case of valid entry return false
      return false
    end
  end
end
