module SSOAPI
  class Handler
    @@api_bind = nil

    # function that bind and initiate the apipie binding to satellite server
    def self.bindAPI
      @@api_bind = ApipieBindings::API.new({:uri => $options[:url], :username => $options[:user], :password => $options[:pass], :api_version => '2', :timeout => $options[:timeout]}, {:verify_ssl => $options[:verify_ssl]})
    end

    # function that make the api call to satellite server
    def self.apiCall(resource, action, params, exiting = false)
      # params.merge!({:organization_id => @options[:org], :page => page, :per_page => 100})
      # merge organization_id parameter with the one passed in the options
      params.merge!({:organization_id => $options[SSO::Constants::SATELLITE_ORGANIZATION]})
      puts "Calling APIPIE resource: #{resource}, action: #{action} with params #{params}"
      return 0
      attempt = 0
      # try to make the api call
      while attempt <= $options[SSO::Constants::API_MAX_STEP]
        begin
          response = @@api_bind.resource(resource).call(action, params)
        rescue RestClient::ExceptionWithResponse => exception
          # if the api call fails check the error and raise the number of attempt maded
          self.handleError attempt, exception
          attempt += 1
        end
      end
      return response
    end

    # function that retrieve all data from paginated api like :index action of the api resources
    def self.fetchAllResults(resource, action, params)
      restURL = self.createAPIURL apiURL
      page = SSO::Constants::API_FIRST_PAGE
      response = nil
      result = []
      morePages = true
      # start to iterate the api calls
      while morePages
        # merge options with the page and per_page value
        options.merge!({:page => page, :per_page => SSO::Constants::API_PER_PAGE})
        # call api
        response = self.apiCall resource, :index,
        page += 1
        # if response of api has results equals aren't equals to per_page value stop parsing
        unless response['results'].length == req['per_page'].to_i
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
      if attempt >= SSO::Constants::API_MAX_ATTEMPTS
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
