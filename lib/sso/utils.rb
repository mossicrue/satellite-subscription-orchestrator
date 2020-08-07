module SSO
  class Utils

    # function to use for exit in case of error
    def self.exitWithError(string, error_code = SSO::Constants::EXIT_GENERIC_ERROR)
      self.putsError string
      exit error_code
    end

    # function to use for exit with error code equals to 0
    def self.exitWith(string)
      self.putsStandard string
      exit SSO::Constants::EXIT_ZERO
    end

    # function to use in case of exit because of a function not implemented yet
    def self.exitWithPending(string)
      self.exitWith "[WIP] #{string} is not implemented yet"
    end

    # function to use for write in standard output, multi-thread compatible
    def self.putsStandard(string)
      # use the moveSpace function also for multithread output option
      spaces, clean_string = self.moveSpace string
      puts "#{spaces}#{clean_string}"
    end

    # function to use for write in standard error, multi-thread compatible
    def self.putsError(string)
      # use the moveSpace function also for multithread output option
      spaces, clean_string = self.moveSpace string
      STDERR.puts "#{spaces}#{clean_string}"
    end

    def self.putsNewLine
      self.putsStandard "\n"
    end

    # function to use for write output in verbose mode
    def self.putsVerbose(string)
      if self.verbose?
        spaces, clean_string = self.moveSpace string
        self.putsStandard "#{spaces}VERBOSE: #{clean_string}"
      end
    end

    # function to use for write output in debug mode
    def self.putsDebug(string)
      if self.debug?
        spaces, clean_string = self.moveSpace string
        self.putsStandard "#{spaces}DEBUG: #{clean_string}"
      end
    end

    # function that move the space for handle output like verbose, debug or concurrency one
    # return 2 strings: 1st with the leading space, 2nd with the string without spaces
    def self.moveSpace(string)
      # create the string with all the leading spaces
      spaces = string[/\A */]
      # create the stribg by stripping leadins spaces
      clean_string = string.strip
      return spaces, clean_string
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
    def self.loadYAMLFile(file_path, exit_on_error = true)
      # try to load a file
      begin
        loaded_file = YAML.load_file file_path
      # rescue the file not found
      rescue Errno::ENOENT
        if exit_on_error
          SSO::Utils::exitWithError "FATAL ERROR: File #{file_path} not found! Exiting", SSO::Constants::EXIT_FILE_NOT_FOUND
        else
          # may not exit with error in case of cache file
          SSO::Utils::putsError "WARNING: File #{file_path} not found!"
          return
        end
      end
      return loaded_file
    end

    # function that return a section of a yaml file
    def self.loadYAMLFileSection(file_path, section, exit_on_error = true)
      loaded_file = self.loadYAMLFile file_path, exit_on_error
      unless loaded_file.has_key? section
        self.exitWithError "FATAL ERROR: Section #{section} not found in file #{file_path}", SSO::Constants::EXIT_CONFIGURATION_MISSING_SECTION
      end
      return loaded_file[section]
    end

    # function used for build search string for subscriptions
    def self.createSearch(search)
      # if string to search is a string return it without doing anything
      if search.is_a? String
        return "\"#{search}\""
      # if it's a hash trasform it in array and recall the function
      elsif search.is_a? Hash
        args = search.collect do |key, value|
          "#{key}=#{self.createSearch value}"
        end
        self.createSearch args
      # if it's an array map all the elements joining them with an 'and'
      elsif search.is_a? Array
        search.compact.map { |item| item.is_a?(Hash) ? self.createSearch(item) : item }.join(' and ')
      else
        return search
      end
    end
  end
end
