module SSOOptionParser
  class Binding

    @@parsedOptions = {}

    ## MARK: Subcommand Options Tree
    SUBCOMMAND_TREE = {
      # global settings, I mean, first help when you type ./SSO --help
      SSO::Constants::CMD_GLOBAL => OptionParser.new do |opts|
        opts.banner = "Usage: #{opts.program_name} [options]"
        opts.version = SSO::Constants::PROGRAM_VERSION
        # connection options
        opts.on("-U", "--url=URL", "URL to the Satellite") do |url|
          @options[:url] = url
        end
        opts.on("-t", "--timeout=TIMEOUT", OptionParser::DecimalInteger, "Timeout value in seconds for any API calls. -1 means never timeout") do |timeout|
          @options[:timeout] = timeout
        end
        opts.on("-u", "--user=USER", "User to log in to Satellite") do |user|
          @options[:user] = user
        end
        opts.on("-p", "--pass=PASS", "Password to log in to Satellite") do |password|
          @options[:pass] = password
        end
        opts.on("-o", "--organization-id=ID", OptionParser::DecimalInteger, "Organization ID to manage subscriptions") do |organization|
          @options[:org] = organization
        end
        opts.on("--no-verify-ssl", "don't verify SSL certs") do
          @options[:verify_ssl] = false
        end
        opts.on("-c", "--config=FILE", "configuration file in YAML format") do |conf|
          # to be refactored in :conf_file
          @options[:config_file] = conf
        end
        # extra behaviour options
        opts.on("--multiple-search", "Allow to search content-hosts with the order of query result in configuration file") do
          @options[:multi_search] = true
        end
        opts.on("--clean-same-product", "Ensure that all the content hosts has the right number of subscriptions for every product to be attached") do
          @options[:clean_same_sub] = true
        end
        opts.on("--host-auto-heal=VALUE", "Disable or enable auto-attach process on Satellite content hosts (Accepted value: 'noop' 'Enable' or 'Disable')") do |setting|
          if setting.downcase == "enable" or setting.downcase == "disable"
            @options[:auto_heal] = setting.downcase
          else
            @options[:auto_heal] = "noop"
          end
        end
        ### leaving this 2 options commented as I have to better check the virt-who version that upload facts
        ### opts.on("--virt-who", "use the command virt-who --print to retrieve the cpu.cpu_socket(s)'s data of the hypervisors.") do
        ###   @options[:virtwho] = true
        ### end
        ### opts.on("--virt-who-file=FILE", "read or write to virt-who cache file, based on --read-from-cache value and --virt-who.") do |vwf|
        ###   @options[:virtwhocachefile] = vwf
        ### end
        # complex data center options
        opts.on("--empty-hypervisor", "Remove all the subscriptions from hypervisors without guests. Not compatible with --density* options.") do
          @options[:empty_hypervisor] = true
        end
        opts.on("--density", "Check if all virt-who reported clusters have an average number of vm >= 4. Not compatible with --empty-hypervisor option.") do
          @options[:density] = true
        end
        opts.on("--density-value=VALUE", OptionParser::DecimalInteger, "Change the average number of vm to check on all virt-who reported clusters. Not compatible with --empty-hypervisor option.") do |value|
          @options[:density_value] = value
        end
        ### Still to be implement in the other setting, can increase entrophy of control for guests
        opts.on("--density-force-vdc", "Force to use datacenter subscriptions for vm guests if hypervisor isn't subscribed. This options is intended for reports in case of insufficient subscriptions pool. Not compatible with --empty-hypervisor") do
          @options[:force_density] = true
        end
        # report options
        opts.on("--density-file=FILE", "Custom file in which create the cluster state report. Not compatible with --empty-hypervisor option.") do |df|
          @options[:density_file] = df
        end
        opts.on("--print-subscription-report", "Create a CSV report with the subscription status of the Environment") do
          @options[:sub_report] = true
        end
        opts.on("--print-subscription-report-file=FILE", "Custom CSV file in which print the subscription status") do |file|
          @options[:sub_report_file] = file
        end
        # API Options
        opts.on("--repeat-api", "Repeat an API call for a certain number of time in case of error") do
          @options[:api_repeat] = true
        end
        opts.on("--repeat-api-step=MAX_STEP", OptionParser::DecimalInteger, "Maximum number of time to retry the failing API Call") do |step|
          @options[:api_max_step] = step
        end
        opts.on("--repeat-api-sleep", "Add an incremental waiting time between a failing tentative of API Call and the next one") do
          @options[:api_sleep] = true
        end
        opts.on("--repeat-api-sleep-time=TIME_IN_SECONDS", OptionParser::DecimalInteger, "Set the waiting time between a failing tentative of API Call and the next one") do |wait|
          @options[:api_sleep_time] = wait
        end
        opts.on("--repeat-api-sleep-multiplier=MULTIPLIER", OptionParser::DecimalInteger, "Set the incremental factor between a failing tentative of API Call and the next one") do |mult|
          @options[:api_sleep_mult] = wait
        end
        # Concurrency options
        opts.on("--concurrency", "Enable subscription assignament to hosts to run with parallel threads setted in configuration file") do
          @options[:concurrency] = true
        end
        opts.on("--concurrency-thread=MAX_THREAD", OptionParser::DecimalInteger, "Number of max concurrent threads to be run in parrallel") do |thread|
          @options[:concurrency_max_thread] = thread
        end
        # source options
        opts.on("--read-from-cache", "Read data from cache file, if possible") do
          @options[:use_cache] = true
        end
        opts.on("--cache-file=FILE", "Cache file to be read and write") do |file|
          @options[:cache_file] = file
        end
        # Verbosity options
        opts.on("-v", "--verbose", "Set the output of the script to verbose level") do
          @options[:verbose] = true
        end
        opts.on("-d", "--debug", "Set the output of the script to debug level") do
          @options[:verbose] = true
          @options[:debug] = true
        end
        opts.on("-n", "--noop", "Do not actually attach or remove any subscriptions") do
          @options[:noop] = true
        end
      end
    }

    def self.getOptionParser(command)
      if not SUBCOMMAND_TREE.has_key? command
        SSO::Utils::exitWithError "SUBCOMMAND #{command} not expected. Exiting", SSO::Constants::EXIT_INVALID_SUBCOMMAND
      end
      return SUBCOMMAND_TREE[command]
    end

    def self.getParsedOptions()
      return @@parsedOptions
    end

  end
end
