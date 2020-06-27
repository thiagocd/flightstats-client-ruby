require 'cgi'
require 'json'

module FlightStats
  class API
    # The superclass to all errors that occur when making an API request.
    class ResponseError < Error
      attr_reader :request
      attr_reader :response

      def initialize request, response
        @request, @response = request, response
      end

      def to_s
        if description
          return CGI.unescapeHTML [description, details].compact.join(' ')
        end

        return super unless http_status_code
        "%d %s (%s %s)" % [
            http_status_code, http_error, request.method, API.base_uri + request.path
        ]
      end

      def message
        json and json['error'] and json['error']['errorMessage']
      end

      def code
        json and json['error'] and json['error']['errorCode']
      end

      def http_status_code
        json and json['error'] and json['error']['httpStatusCode']
      end

      private

      def http_error
        Helper.demodulize self.class.name.gsub(/([a-z])([A-Z])/, '\1 \2')
      end

      def json
        return @json if defined? @json
        @json = (JSON.parse(response.body) if response && !response.body.empty?)
      end
    end

    # === 3xx Redirection
    #
    # Not an error, per se, but should result in one in the normal course of
    # API interaction.
    class Redirection < ResponseError
    end

    # === 4xx Client Error
    #
    # The superclass to all client errors (responses with status code 4xx).
    class ClientError < ResponseError
    end

    # === 400 Bad Request
    #
    # Something was wrong with the request submitted, and it must be corrected
    # before it can succeed. The response body will include details about the error.
    class BadRequest < ClientError
    end

    # === 403 Forbidden
    #
    # Authorization failure; valid credentials were not provided.
    class Forbidden < ClientError
    end

    # === 404 Not Found
    #
    # No resource was found at the specified URI.
    class NotFound < ClientError
    end

    # === 405 Method Not Allowed
    #
    # The HTTP request specified a method (e.g. PUT, DELETE, OPTIONS, etc.)
    # that is not supported by this resource.
    class MethodNotAllowed < ClientError
    end

    # === 5xx Server Error
    #
    # The superclass to all server errors (responses with status code 5xx).
    class ServerError < ResponseError
    end

    # === 500 Internal Server Error
    #
    # Unexpected server-side failure. Should this occur, please contact us
    # for assistance. The response body will include a unique identifier
    # that we can use to help locate the problem.
    class InternalServerError < ServerError
    end

    # Error mapping by status code.
    ERRORS = Hash.new { |hash, code|
      unless hash.key? code
        case code
          when 400...500 then ClientError
          when 500...600 then ServerError
          else                ResponseError
        end
      end
    }.update(
      400 => BadRequest,
      403 => Forbidden,
      404 => NotFound,
      405 => MethodNotAllowed,
      500 => InternalServerError
    ).freeze
  end
end