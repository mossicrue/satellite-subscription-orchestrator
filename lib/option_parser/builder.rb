module SSOOptionParser
  class Builder
    # initialize the global parser, passing the Global sub command
    def self.initializeGlobalParser()
      return self.initializeParser SSO::Constants::CMD_GLOBAL
    end

    # initialize the option parser for the passed command, must be present in the SUBCOMMAND_TREE
    def self.initializeParser(command)
      return SSOOptionParser::Binding::getOptionParser command
    end
  end
end
