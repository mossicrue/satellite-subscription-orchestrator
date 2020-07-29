module SSO
  class Utils
    def self.exitWithError(string, error_code = SSO::Constants::EXIT_GENERIC_ERROR)
      self.putsError string
      exit error_code
    end

    def self.exitWith(string)
      puts string
      exit SSO::Constants::EXIT_ZERO
    end

    def self.exitWithPending(string)
      self.exitWith "[WIP] #{string} is not implemented yet"
    end

    def self.putsError(string)
      STDERR.puts "FATAL ERROR: #{string}"
    end

    def self.putsVerbose(string)
      if self.verbose?
        puts "VERBOSE: #{string}"
      end
    end

    def self.putsDebug(string)
      if self.debug?
        puts "  DEBUG: #{string}"
      end
    end

    def self.verbose?
      return $options[:verbose]
    end

    def self.debug?
      return $options[:debug]
    end

    def self.showVersion
      self.exitWith "#{SSO::Constants::PROGRAM_NAME} #{SSO::Constants::PROGRAM_VERSION}"
    end

    def self.loadYAMLFileSection(file_path, section)
      loaded_file = self.loadYAMLFile file_path
      unless loaded_file.has_key? section
        self.exitWithError "FATAL ERROR: Section #{section} not found in file #{file_path}", SSO::Constants::EXIT_CONFIGURATION_MISSING_SECTION
      end
      return loaded_file[section]
    end

    def self.loadYAMLFile(file_path)
      begin
        file_path = YAML.load_file file_path
      rescue Errno::ENOENT
        SSO::Utils::exitWithError "FATAL ERROR: Configuration file #{$options[:config_file]} not found! Exiting", SSO::Constants::EXIT_FILE_NOT_FOUND
      end
      return file
    end
  end
end
