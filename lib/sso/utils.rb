module SSO
  class Utils

    # function to use for exit in case of error
    def self.exitWithError(string, error_code = SSO::Constants::EXIT_GENERIC_ERROR)
      self.putsError string
      exit error_code
    end

    # function to use for exit with error code equals to 0
    def self.exitWith(string)
      puts string
      exit SSO::Constants::EXIT_ZERO
    end

    # function to use in case of exit because of a function not implemented yet
    def self.exitWithPending(string)
      self.exitWith "[WIP] #{string} is not implemented yet"
    end

    # function to use for write in standard output, multi-thread compatible
    def self.putsStandard(string)
      # for multithread output option
      puts "#{string}"
    end

    # function to use for write in standard error, multi-thread compatible
    def self.putsError(string)
      STDERR.puts "#{string}"
    end

    # function to use for write output in verbose mode
    def self.putsVerbose(string)
      if self.verbose?
        self.putsStandard "VERBOSE: #{string}"
      end
    end

    # function to use for write output in debug mode
    def self.putsDebug(string)
      if self.debug?
        self.putsStandard "  DEBUG: #{string}"
      end
    end

    # function that return the state of verbose option
    def self.verbose?
      return $options[:verbose]
    end

    # function that return the state of debug option
    def self.debug?
      return $options[:debug]
    end

    # function that return the version of the program
    def self.showVersion
      self.exitWith "#{SSO::Constants::PROGRAM_NAME} #{SSO::Constants::PROGRAM_VERSION}"
    end

    # function that load and parse a yaml file
    def self.loadYAMLFile(file_path)
      begin
        file_path = YAML.load_file file_path
      rescue Errno::ENOENT
        SSO::Utils::exitWithError "FATAL ERROR: Configuration file #{$options[:config_file]} not found! Exiting", SSO::Constants::EXIT_FILE_NOT_FOUND
      end
      return file
    end

    # function that return a section of a yaml file
    def self.loadYAMLFileSection(file_path, section)
      loaded_file = self.loadYAMLFile file_path
      unless loaded_file.has_key? section
        self.exitWithError "FATAL ERROR: Section #{section} not found in file #{file_path}", SSO::Constants::EXIT_CONFIGURATION_MISSING_SECTION
      end
      return loaded_file[section]
    end

    # function used for build search string for subscriptions
    def self.search_args(search)
      # if string to search is a string return it without doing anything
      if search.is_a? String
        return "\"#{search}\""
      # if it's a hash trasform it in array and recall the function
      elsif search.is_a? Hash
        args = search.collect do |key, value|
          "#{key}=#{self.search_args value}"
        end
        self.search_args args
      # if it's an array map all the elements joining them with an 'and'
      elsif search.is_a? Array
        search.compact.map { |item| item.is_a?(Hash) ? self.search_args(item) : item }.join(' and ')
      else
        return search
      end
    end
  end
end
