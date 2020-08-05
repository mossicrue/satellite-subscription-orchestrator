module SSOOptionParser
  class Binding
    @@parsed_options = {}
    ## MARK: Subcommand Options Tree
    SUBCOMMAND_TREE = {
      # global settings, I mean, first help when you type ./SSO --help
      SSO::Constants::CMD_GLOBAL => OptionParser.new do |opts|
        opts.banner = "Satellite Subscription Orchestrator: a powerful tool for subscribing Satellite servers without any pain\n\nUSAGE:\n#{opts.program_name} [options]\n\nOPTIONS:"
        opts.version = SSO::Constants::PROGRAM_VERSION
        # connection options
        opts.on("-U", "--url=URL", "URL to the Satellite") do |url|
          @@parsed_options[:url] = url
        end
        opts.on("-t", "--timeout=TIMEOUT", OptionParser::DecimalInteger, "Timeout value in seconds for any API calls. -1 means never timeout") do |timeout|
          @@parsed_options[:timeout] = timeout
        end
        opts.on("-u", "--user=USER", "User to log in to Satellite") do |user|
          @@parsed_options[:user] = user
        end
        opts.on("-p", "--pass=PASS", "Password to log in to Satellite") do |password|
          @@parsed_options[:pass] = password
        end
        opts.on("-o", "--organization-id=ID", OptionParser::DecimalInteger, "Organization ID to manage subscriptions") do |organization|
          @@parsed_options[:org] = organization
        end
        opts.on("--no-verify-ssl", "don't verify SSL certs") do
          @@parsed_options[:verify_ssl] = false
        end
        opts.on("-c", "--config=FILE", "configuration file in YAML format") do |conf|
          # to be refactored in :conf_file
          @@parsed_options[:config_file] = conf
        end
        # extra behaviour options
        opts.on("--multiple-search", "Allow to search content-hosts with the order of query result in configuration file") do
          @@parsed_options[:multi_search] = true
        end
        opts.on("--clean-same-product", "Ensure that all the content hosts has the right number of subscriptions for every product to be attached") do
          @@parsed_options[:clean_same_sub] = true
        end
        opts.on("--host-auto-heal=VALUE", "Disable or enable auto-attach process on Satellite content hosts (Accepted value: 'noop' 'Enable' or 'Disable')") do |setting|
          if setting.downcase == "enable" or setting.downcase == "disable"
            @@parsed_options[:auto_heal] = setting.downcase
          else
            @@parsed_options[:auto_heal] = "noop"
          end
        end
        ### leaving this 2 options commented as I have to better check the virt-who version that upload facts
        ### opts.on("--virt-who", "use the command virt-who --print to retrieve the cpu.cpu_socket(s)'s data of the hypervisors.") do
        ###   @@parsed_options[:virtwho] = true
        ### end
        ### opts.on("--virt-who-file=FILE", "read or write to virt-who cache file, based on --read-from-cache value and --virt-who.") do |vwf|
        ###   @@parsed_options[:virtwhocachefile] = vwf
        ### end
        # complex data center options
        opts.on("--empty-hypervisor", "Remove all the subscriptions from hypervisors without guests. Not compatible with --density* options.") do
          @@parsed_options[:empty_hypervisor] = true
        end
        opts.on("--density", "Check if all virt-who reported clusters have an average number of vm >= 4. Not compatible with --empty-hypervisor option.") do
          @@parsed_options[:density] = true
        end
        opts.on("--density-value=VALUE", OptionParser::DecimalInteger, "Change the average number of vm to check on all virt-who reported clusters. Not compatible with --empty-hypervisor option.") do |value|
          @@parsed_options[:density_value] = value
        end
        ### Still to be implement in the other setting, can increase entrophy of control for guests
        opts.on("--density-force-vdc", "Force to use datacenter subscriptions for vm guests if hypervisor isn't subscribed. This options is intended for reports in case of insufficient subscriptions pool. Not compatible with --empty-hypervisor") do
          @@parsed_options[:force_density] = true
        end
        # report options
        opts.on("--density-file=FILE", "Custom file in which create the cluster state report. Not compatible with --empty-hypervisor option.") do |df|
          @@parsed_options[:density_file] = df
        end
        opts.on("--print-subscription-report", "Create a CSV report with the subscription status of the Environment") do
          @@parsed_options[:sub_report] = true
        end
        opts.on("--print-subscription-report-file=FILE", "Custom CSV file in which print the subscription status") do |file|
          @@parsed_options[:sub_report_file] = file
        end
        # API Options
        opts.on("--repeat-api", "Repeat an API call for a certain number of time in case of error") do
          @@parsed_options[:api_repeat] = true
        end
        opts.on("--repeat-api-step=MAX_STEP", OptionParser::DecimalInteger, "Maximum number of time to retry the failing API Call") do |step|
          @@parsed_options[:api_max_step] = step
        end
        opts.on("--repeat-api-sleep", "Add an incremental waiting time between a failing tentative of API Call and the next one") do
          @@parsed_options[:api_sleep] = true
        end
        opts.on("--repeat-api-sleep-time=TIME_IN_SECONDS", OptionParser::DecimalInteger, "Set the waiting time between a failing tentative of API Call and the next one") do |wait|
          @@parsed_options[:api_sleep_time] = wait
        end
        opts.on("--repeat-api-sleep-multiplier=MULTIPLIER", OptionParser::DecimalInteger, "Set the incremental factor between a failing tentative of API Call and the next one") do |mult|
          @@parsed_options[:api_sleep_mult] = wait
        end
        # Concurrency options
        opts.on("--concurrency", "Enable subscription assignament to hosts to run with parallel threads setted in configuration file") do
          @@parsed_options[:concurrency] = true
        end
        opts.on("--concurrency-thread=MAX_THREAD", OptionParser::DecimalInteger, "Number of max concurrent threads to be run in parrallel") do |thread|
          @@parsed_options[:concurrency_max_thread] = thread
        end
        # source options
        opts.on("--read-from-cache", "Read data from cache file, if possible") do
          @@parsed_options[:use_cache] = true
        end
        opts.on("--cache-file=FILE", "Cache file to be read and write") do |file|
          @@parsed_options[:cache_file] = file
        end
        # Verbosity options
        opts.on("-v", "--verbose", "Set the output of the script to verbose level") do
          @@parsed_options[:verbose] = true
        end
        opts.on("-d", "--debug", "Set the output of the script to debug level") do
          @@parsed_options[:verbose] = true
          @@parsed_options[:debug] = true
        end
        opts.on("-n", "--noop", "Do not actually attach or remove any subscriptions") do
          @@parsed_options[:noop] = true
        end
        opts.separator("\n")
      end
    }

    # return the optionparser of the given command
    def self.getOptionParser(command)
      # if the command doesn't exists in the SUBCOMMAND_TREE exit
      unless SUBCOMMAND_TREE.has_key? command
        SSO::Utils::exitWithError "SUBCOMMAND #{command} not expected. Exiting", SSO::Constants::EXIT_INVALID_SUBCOMMAND
      end
      return SUBCOMMAND_TREE[command]
    end

    # return all the parsed options
    def self.getParsedOptions()
      if self.checkOptionsIntegrity
        return SSOOptionParser::Defaults::refineOptions @@parsed_options
      end
    end

    # check the presence of incogruence options with a chain of rules
    def self.checkOptionsIntegrity
      # --empty-hypervisor option can't work with --density options
      if @@parsed_options[:empty_hypervisor] and @@parsed_options[:density]
        SSO::Utils::exitWithError "FATAL ERROR: both --empty_hypervisor and --density options enabled. Use only one or see the script's usage.", SSO::Constants::EXIT_INCONGRUENT_OPTIONS
      end
      # satellite connection url must be https
      unless @@parsed_options[:url].start_with?('https://')
        SSO::Utils::exitWithError "FATAL ERROR: URL to Satellite must start with https.", SSO::Constants::EXIT_INCONGRUENT_OPTIONS
      end
      # if parsed_options are all good return true
      return true
    end
  end
end
