module SSO
  class Constants
    # general purpose constants of the SSO tools
    PROGRAM_NAME = "Satellite Subscription Orchestrator".freeze
    PROGRAM_VERSION = "0.0.1 pre-alpha"
    SATELLITE_ORGANIZATION = :org

    # option-parser commands for satellite attach subscription tools
    CMD_GLOBAL = "global"

    # options symbols
    # OPTIONS_CONFIGURATION_FILE = :config_file

    # api constants
    API_MAX_STEP = :api_max_step
    API_SLEEP_TIME = :api_sleep_time
    API_SLEEP_MULTIPLIER = :api_sleep_mult
    API_FIRST_PAGE = 0
    API_PER_PAGE = 100

    # exit code of SSO
    EXIT_ZERO = 0
    EXIT_GENERIC_ERROR = 1
    EXIT_INVALID_PARSE = 10
    EXIT_INVALID_SUBCOMMAND = 11
    EXIT_INCONGRUENT_OPTIONS = 12
    EXIT_FILE_NOT_FOUND = 20
    EXIT_API_GENERIC_ERROR = 30
    EXIT_CONFIGURATION_GENERIC_ERROR = 40
    EXIT_CONFIGURATION_MISSING_SECTION = 41

  end
end
