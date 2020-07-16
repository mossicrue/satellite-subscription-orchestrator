module SASOptionParser
  class Parser
    def self.parse(optionParser, passedArguments)
      command = ""
      options = {}
      self.checkArguments optionParser, passedArguments
      while passedArguments.size > 0
        command = self.buildCommand command, passedArguments.shift
        subOptionParser = SASOptionParser::Builder::initializeParser command
        self.parseOptions subOptionParser
        options = SASOptionParser::Binding::getParsedOptions
      end
      # I need to think if this functions can be usefull here or moved in every dispatched functions,
      # for now I think that the function will be commented also for a easy developing
      # self.checkParsedOptions options, subOptionParser
      return command, options
    end

    def self.checkArguments(optionParser, passedArguments)
      if passedArguments.size == 0
        self.printHelp optionParser
      end
    end

    def self.buildCommand(oldCommand, newCommand)
      if not oldCommand.size == 0
        oldCommand.concat "_"
      end
      return oldCommand.concat newCommand
    end

    def self.parseOptions(optionParser)
      begin
        optionParser.order!
      rescue OptionParser::ParseError => exception
        SAS::Utils::exitWithError "#{exception}\n\n See #{SASSettings::Constants::PROGRAM_NAME} --help", SAS::Constants::INVALID_PARSE
      end
    end

    def self.printHelp(optionParser)
      SAS::Utils::exitWith optionParser.help
    end
  end
end
