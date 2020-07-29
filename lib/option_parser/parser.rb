module SSOOptionParser
  class Parser
    def self.parse(optionParser, passedArguments)
      command = ""
      $options = {}
      self.checkArguments optionParser, passedArguments
      while passedArguments.size > 0
        command = self.buildCommand command, passedArguments.shift
        subOptionParser = SSOOptionParser::Builder::initializeParser command
        self.parseOptions subOptionParser
        $options = SSOOptionParser::Binding::getParsedOptions
      end
      return command
    end

    def self.checkArguments(optionParser, passedArguments)
      if passedArguments.size == 0
        self.printHelp optionParser
      end
    end

    def self.buildCommand(oldCommand, newCommand)
      unless oldCommand.size == 0
        oldCommand.concat "_"
      end
      return oldCommand.concat newCommand
    end

    def self.parseOptions(optionParser)
      begin
        optionParser.order!
      rescue OptionParser::ParseError => exception
        SSO::Utils::exitWithError "#{exception}\n\n See #{SSOSettings::Constants::PROGRAM_NAME} --help", SSO::Constants::INVALID_PARSE
      end
    end

    def self.printHelp(optionParser)
      SSO::Utils::exitWith optionParser.help
    end
  end
end
