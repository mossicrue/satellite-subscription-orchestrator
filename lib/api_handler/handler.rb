module SSOAPI
  class Handler

    

    def self.apiCall(resource, action, params, exiting = false)
      puts "Calling APIPIE resource: #{resource}, action: #{action} with params #{params}"
    end

    def self.makeRequest(restURL, options)
      return "Calling #{restURL} with options #{options}"
      attempt = 0
      while attempt <= HPSMTool::Settings::API_MAX_ATTEMPTS
        begin
          response = RestClient::Request::execute method: get, url: restURL, header: options, user: HPSMTool::Settings::API_USERNAME, pass: HPSMTool::Settings::API_PASSWORD
        rescue RestClient::ExceptionWithResponse => exception
          self.handleError attempt, exception
          attempt += 1
        end
      end
      return response
    end

    def self.fetchAllResults(resource)
      restURL = self.createAPIURL apiURL
      page = HPSMTool::Settings::API_FIRST_PAGE
      response = nil
      result = []
      morePages = true
      while morePages
        # TODO: check the number of FIRST HPSM api page
        options.merge!({HPSMTool::Settings::API_KEY_PAGE => page, HPSMTool::Settings::API_KEY_PERPAGE => HPSMTool::Settings::API_VALUE_PERPAGE})
        response = self.makeRequest restURL, options
        page += 1
        if not HPSMTool::Utils::keyPresent? HPSMTool::Settings::API_KEY_PAGE
          morePages = false
        end
        result.concat response[HPSMTool::Settings::API_KEY_RESULT]
      end
      return result
    end

    def self.handleError(attempt, exception)
      puts "Error during API call to HPSM\n#{exception.message}\n#{exception.response}"
      if attempt >= HPSMTool::Settings::API_MAX_ATTEMPTS
        HPSMTool::Utils::exitWithError "", HPSMTool::ToolError::API_GENERIC_ERROR
      end
      self.sleepAPI attempt
    end

    def sleepAPI(attempt)
      if not HPSMTool::Settings::API_SLEEP
        return
      end
      timeToSleep = HPSMTool::DefautlValue::API_SLEEP_TIME * ( HPSMTool::Settings::API_SLEEP_MULTIPLIER ** attempt )
      sleep timeToSleep
    end

  end
end
