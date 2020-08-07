module SSOOptionParser
  class Defaults
    # default_options of SSO
    @default_options = {
      :url                       => 'https://localhost/',
      :timeout                   => 300,
      :user                      => 'admin',
      :pass                      => 'change_me',
      :org                       => 1,
      :verify_ssl                => true,
      :config_file               => 'config.yaml',
      # :virtwho                 => false,
      # :virtwhocachefile        => 'virt-who.cache',
      :multi_search              => false,
      :clean_same_sub            => false,
      :auto_heal                 => 'noop',
      :empty_hypervisor          => false,
      :density                   => false,
      :density_value             => 4,
      :density_els_value         => 4,
      :density_els_version       => 6,
      :force_density             => false,
      :density_file              => 'cluster-state.csv',
      :guest_report_file         => 'guest-report.csv',
      :sub_report                => false,
      :sub_report_file           => 'sub-report.csv',
      :sub_report_detail_file    => 'detailed-report.csv',
      :api_repeat                => false,
      :api_max_step              => 1,
      :api_sleep                 => false,
      :api_sleep_time            => 0,
      :api_sleep_mult            => 1,
      :concurrency               => false,
      :concurrency_max_thread    => 2,
      :use_cache                 => false,
      :cache_file                => 'sso.cache',
      :verbose                   => false,
      :debug                     => false,
      :noop                      => false
    }

    # merge all the parsed options with the options present in the configuration file and the default ones
    def self.refineOptions(parsed_options)
      # merge with the configuration ones
      parsed_options = self.mergeFromConfiguration parsed_options
      # merge with the defaults options
      parsed_options = self.mergeDefaults parsed_options
      return parsed_options
    end

    # merge the default options with the parsed ones
    def self.mergeDefaults(parsed_options)
      return self.mergeOptions parsed_options, @default_options
    end

    # load configuration file and merge the options under :settings symbol
    def self.mergeFromConfiguration(parsed_options)
      # load file with rescue
      begin
        configuration_file = YAML.load_file parsed_options[:config_file]
      rescue Errno::ENOENT
        # if not found exit
        SSO::Utils::exitWithError "FATAL ERROR: Configuration file #{parsed_options[:config_file]} not found! Exiting", SSO::Constants::EXIT_FILE_NOT_FOUND
      end
      # if there is any :settings to be passed merge it with the parsed ones
      if configuration_file.has_key? :settings
        parsed_options = self.mergeOptions parsed_options, configuration_file[:settings]
      end
      # return merged options
      return parsed_options
    end

    # TODO: Make test with both instance @ and class @ version of parsed_options and default_options, implement dup in case of problem
    # merge options of the 2 hash, options are not overwritted
    # priority: 1 cli options, 2 config options, 3 default options
    def self.mergeOptions(first_options, second_options)
      second_options.each do |key, val|
        # if first options hasn't an options copy it
        unless first_options.has_key? key
          first_options[key] = val
        end
      end
      return first_options
    end
  end
end
