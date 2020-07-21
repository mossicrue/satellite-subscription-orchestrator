module SSOOptionParser
  class Defaults
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
      :cache_file                => 'sas.cache',
      :verbose                   => false,
      :debug                     => false,
      :noop                      => false
    }

    def self.refineOptions(parsed_options)
      parsed_options = self.mergeDefaults parsed_options
      parsed_options = self.loadFromConfiguration parsed_options
    end

    def self.mergeDefaults(parsed_options)
      # add to parsed options the missing ones in defaults class
      @default_options.each do |key, val|
        if not parsed_options.has_key? key
          parsed_options[key] = val
        end
      end
      return parsed_options
    end

    def self.loadFromConfiguration(parsed_options)
      begin
        configuration_file = YAML.load_file parsed_options[:conf_file]
      rescue Errno::ENOENT
        SSO::Utils::exitWithError "FATAL ERROR: Configuration file #{parsed_options[:config_file]} not found! Exiting", SSO::Constants::EXIT_FILE_NOT_FOUND
      end
      # TODO: load the keys and merge with it, create a second function using defaults and loaded hash from yaml and rename mergeDefaults with more generic mergeOptions(options1, options 2)
    end
  end
end
