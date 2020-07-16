module SASOptionParser
  class Builder
    def self.initializeGlobalParser()
      return self.initializeParser SAS::Constants::CMD_GLOBAL
    end

    def self.initializeParser(command)
      return SASOptionParser::Binding::getOptionParser command
    end
  end
end
