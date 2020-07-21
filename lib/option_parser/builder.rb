module SSOOptionParser
  class Builder
    def self.initializeGlobalParser()
      return self.initializeParser SSO::Constants::CMD_GLOBAL
    end

    def self.initializeParser(command)
      return SSOOptionParser::Binding::getOptionParser command
    end
  end
end
