module SASOptionParser
  class Binding

    @@parsedOptions = {}

    ## MARK: Subcommand Options Tree
    SUBCOMMAND_TREE = {
      # global settings, I mean, first help when you type ./SAS --help
      SAS::Constants::CMD_GLOBAL => OptionParser.new do |opts|
        opts.banner = "Usage: #{opts.program_name} [options]"
        opts.version = SAS::Constants::PROGRAM_VERSION
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
        opts.on("-o", "--organization-id=ID", "ID of the Organization to manage subscriptions") do |organization|
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
        opts.on("--multiple-search", "Allow to search content-hosts with the order of query result in yaml configuration file") do
          @options[:multi_search] = true
        end
        opts.on("--clean-same-product", "Ensure that all the content hosts has 1 subscriptions for every product found from yaml configuration file") do
          @options[:clean_sub] = true
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
        opts.on("--empty-hypervisor", "Remove all the subscriptions from hypervisors without guests. Not compatible with --density and --density-* options.") do
          @options[:empty_hypervisor] = true
        end
        opts.on("--density", "check if all hosts in a cluster has an average number of guests >= 5 for assigning VDC Subscription. Not compatible with --empty-hypervisor option.") do
          @options[:density] = true
        end
        opts.on("--density-value=VALUE", "check if all hosts in a cluster has an average number of guests >= VALUE for assigning VDC Subscription. Not compatible with --empty-hypervisor option.") do |value|
          @options[:density_value] = value
        end
        ### Still to be implement in the other setting, can increase entrophy of control for guests
        opts.on("--force-density", "Force to use datacenter subscriptions for vm guests of subscribed hypervisor. To use in case of report with insufficient subscriptions pool. Not compatible with --empty-hypervisor") do
          @options[:force_density] = true
        end
        # report options
        opts.on("--density-file=FILE", "Write report of cluster state to custom file. Not compatible with --empty-hypervisor option.") do |df|
          @options[:density_file] = df
        end
        opts.on("--print-subscription-report", "Print a report for the subscription used by of all hosts") do
          @options[:sub_report] = true
        end
        opts.on("--print-subscription-report-file=FILE", "Print a report for the subscription in a custom file used by of all hosts") do |srf|
          @options[:sub_report_file] = srf
        end
        # API Options
        opts.on("--repeat-api", "Allow to repeat API for a certain number before fail") do
          @options[:api_repeat] = true
        end
        opts.on("--repeat-api-step=MAX_STEP", "Set the number of maximum tentative which API try to repeat API Call in case of fails") do |step|
          @options[:api_max_step] = step
        end
        opts.on("--repeat-api-sleep", "Allow to add an incremental waiting time configurable via configuration file") do
          @options[:api_sleep] = true
        end
        opts.on("--repeat-api-sleep-time=TIME_IN_SECONDS") do |wait|
          @options[:api_sleep_time] = wait
        end
        opts.on("--repeat-api-sleep-multiplier=MULTIPLIER") do |mult|
          @options[:api_sleep_mult] = wait
        end
        # Concurrency options
        opts.on("--concurrency", "Allow to assign subscription to hosts in parallel, as setted in configuration file") do
          @options[:concurrency] = true
        end
        opts.on("--concurrency-thread=MAX_THREAD", "Number of max concurrent thread to be run in parrallel") do |thread|
          @options[:concurrency_max_thread] = thread
        end
        # Verbosity options
        opts.on("-v", "--verbose", "verbose output for the script") do
          @options[:verbose] = true
        end
        opts.on("-d", "--debug", "debug output for the script") do
          @options[:verbose] = true
          @options[:debug] = true
        end
        opts.on("-n", "--noop", "do not actually execute anything") do
          @options[:noop] = true
        end
      end
    }

    def self.getOptionParser(command)
      if not SUBCOMMAND_TREE.has_key? command
        SAS::Utils::exitWithError "SUBCOMMAND #{command} not expected. Exiting", SAS::Constants::EXIT_INVALID_SUBCOMMAND
      end
      return SUBCOMMAND_TREE[command]
    end

    def self.getParsedOptions()
      return @@parsedOptions
    end

  end
end
