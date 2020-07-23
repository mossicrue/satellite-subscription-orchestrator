module SSO
  class Constants
    # general purpose constants of the SSO tools
    PROGRAM_NAME = "Satellite Subscription Orchestrator".freeze
    PROGRAM_VERSION = "0.0.1 pre-alpha"

    # option-parser commands for satellite attach subscription tools
    CMD_GLOBAL = "global"

    # options symbols
    # OPTIONS_CONFIGURATION_FILE = :config_file

    # configuration symbols

    # exit code of SSO
    EXIT_ZERO = 0
    EXIT_GENERIC_ERROR = 1
    EXIT_INVALID_PARSE = 10
    EXIT_INVALID_SUBCOMMAND = 11
    EXIT_FILE_NOT_FOUND = 20

  end
end
