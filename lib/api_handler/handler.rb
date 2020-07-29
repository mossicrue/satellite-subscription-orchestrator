module SSOAPI
  class Handler
    @@api_bind = nil

    def self.bindAPI
      @@api_bind = ApipieBindings::API.new({:uri => $options[:url], :username => $options[:user], :password => $options[:pass], :api_version => '2', :timeout => $options[:timeout]}, {:verify_ssl => $options[:verify_ssl]})
    end

    def self.apiCall(resource, action, params, exiting = false)
      # params.merge!({:organization_id => @options[:org], :page => page, :per_page => 100})
      params.merge! {:organization_id => $options[SSO::Constants::SATELLITE_ORGANIZATION]}
      puts "Calling APIPIE resource: #{resource}, action: #{action} with params #{params}"
      return 0
      attempt = 0
      while attempt <= $options[SSO::Constants::API_MAX_STEP]
        begin
          response = @@api_bind.resource(resource).call(action, params)
        rescue RestClient::ExceptionWithResponse => exception
          self.handleError attempt, exception
          attempt += 1
        end
      end
      return response
    end

    def self.fetchAllResults(resource, action, params)
      restURL = self.createAPIURL apiURL
      page = SSO::Constants::API_FIRST_PAGE
      response = nil
      result = []
      morePages = true
      while morePages
        options.merge!({:page => page, :per_page => SSO::Constants::API_PER_PAGE})
        response = self.apiCall resource, :index,
        page += 1
        if not response['results'].length == req['per_page'].to_i
          morePages = false
        end
        result.concat response['results']
      end
      return result
    end

    def self.handleError(attempt, exception)
      SSO::Utils::putsError "Error during API call to Satellite\n#{exception.message}\n#{exception.response}"
      if attempt >= SSO::Constants::API_MAX_ATTEMPTS
        SSO::Utils::exitWithError "FATAL ERROR: Something happened during an API call, see log", SSO::Constants::EXIT_API_GENERIC_ERROR
      end
      self.sleepAPI attempt
    end

    def sleepAPI(attempt)
      if not SSO::Constants::API_SLEEP
        return
      end
      timeToSleep = $options[SSO::Constants::API_SLEEP_TIME] * ( $options[SSO::Constants::API_SLEEP_MULTIPLIER] ** attempt )
      sleep timeToSleep
    end
  end
end
