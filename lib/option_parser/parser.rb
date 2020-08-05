module SSOOptionParser
  class Parser
    # parse all the subcommand and options typed in the command
    def self.parse(optionParser, passedArguments)
      command = ""
      $options = {}
      # check if there isn't any passed arguments
      self.checkArguments optionParser, passedArguments
      # iterate to build command and options
      ###while passedArguments.size > 0
        # build command for SUBCOMMAND_TREE
        ###command = self.buildCommand command, passedArguments.shift
        # build the option parser of the current command
        ###subOptionParser = SSOOptionParser::Builder::initializeParser command
        # parse the options
      self.parseOptions optionParser
        # return the options founded
      $options = SSOOptionParser::Binding::getParsedOptions
    ###  end
    ###  return command
    end

    # if passed arguments are none, print help
    def self.checkArguments(optionParser, passedArguments)
      if passedArguments.size == 0
        SSO::Utils::putsStandard "WARNING: No options passed, see usage\n\n"
        self.printHelp optionParser
      end
    end

    # build command by putting a "_" for SUBCOMMAND_TREE
    def self.buildCommand(oldCommand, newCommand)
      unless oldCommand.size == 0
        oldCommand.concat "_"
      end
      return oldCommand.concat newCommand
    end

    # parse the options typed with the command
    def self.parseOptions(optionParser)
      begin
        optionParser.order!
      rescue OptionParser::ParseError => exception
        SSO::Utils::exitWithError "#{exception}\n\n See #{SSOSettings::Constants::PROGRAM_NAME} --help", SSO::Constants::INVALID_PARSE
      end
    end

    # print the help message
    def self.printHelp(optionParser)
      SSO::Utils::exitWith optionParser.help
    end
  end
end
