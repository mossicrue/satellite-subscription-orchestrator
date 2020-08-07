module SSOAPI
  class Handler
    @@api_bind = nil

    # function that bind and initiate the apipie binding to satellite server
    def self.bindAPI
      @@api_bind = ApipieBindings::API.new({:uri => $options[:url], :username => $options[:user], :password => $options[:pass], :api_version => '2', :timeout => $options[:timeout]}, {:verify_ssl => $options[:verify_ssl]})
    end

    # function that make the api call to satellite server
    def self.apiCall(resource, action, params, exiting = false)
      # merge organization_id parameter with the one passed in the options
      params.merge!({:organization_id => $options[SSO::Constants::SATELLITE_ORGANIZATION]})
      attempt = 0
      # try to make the api call
      while attempt <= $options[SSO::Constants::API_MAX_STEP]
        begin
          response = @@api_bind.resource(resource).call(action, params)
        rescue RestClient::ExceptionWithResponse => exception
          # if the api call fails check the error and raise the number of attempt maded
          self.handleError attempt, exception
          attempt += 1
        rescue StandardError => exception
          self.handleError $options[SSO::Constants::API_MAX_STEP], exception
          ### SSO::Utils::exitWithError "FATAL ERROR: A non RestClient error occured during apicall!\nCheck configuration file and option passed, can this host reach satellite server #{$options[:url]}?\n\nError Stack here:\n#{exception}"
        end
      end
      return response
    end

    # function that retrieve all data from paginated api like :index action of the api resources
    def self.fetchAllResults(resource, action, params, exiting = false)
      page = SSO::Constants::API_FIRST_PAGE
      response = nil
      result = []
      morePages = true
      # start to iterate the api calls
      while morePages
        # merge params with the page and per_page value
        params.merge!({:page => page, :per_page => SSO::Constants::API_PER_PAGE})
        # call api
        response = self.apiCall resource, :index, params, exiting
        page += 1
        # if response of api has results equals aren't equals to per_page value stop parsing
        unless response['results'].length == response['per_page'].to_i
          morePages = false
        end
        # concat the current response with the previous found
        result.concat response['results']
      end
      return result
    end

    # function that handle the error of the api call
    def self.handleError(attempt, exception)
      SSO::Utils::putsError "Error during API call to Satellite\n#{exception.message}\n#{exception.response}"
      # if attempt is >= of max attempts exit with error
      if attempt >= $options[SSO::Constants::API_MAX_STEP]
        SSO::Utils::exitWithError "FATAL ERROR: Something happened during an API call, see log", SSO::Constants::EXIT_API_GENERIC_ERROR
      end
      # otherwise sleep and wait (maybe traffic error or lock of resource)
      self.sleepAPI attempt
    end

    # function that wait before make a second try of an api call
    def sleepAPI(attempt)
      # if api sleep options is disable skip wait
      unless SSO::Constants::API_SLEEP
        return
      end
      # calulate the new value of the sleeptime and sleep
      timeToSleep = $options[SSO::Constants::API_SLEEP_TIME] * ( $options[SSO::Constants::API_SLEEP_MULTIPLIER] ** attempt )
      sleep timeToSleep
    end
  end
end
