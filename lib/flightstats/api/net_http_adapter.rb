require 'cgi'
require 'net/http'
require 'net/https'

module FlightStats
  class API
    module Net
      module HTTPAdapter
        # A hash of Net::HTTP settings configured before the request.
        #
        # @return [Hash]
        def net_http
          @net_http ||= {}
        end

        # Used to store any Net::HTTP settings.
        #
        # @example
        #   FlightStats::API.net_http = {
        #     :verify_mode => OpenSSL::SSL::VERIFY_PEER,
        #     :ca_path     => "/etc/ssl/certs",
        #     :ca_file     => "/opt/local/share/curl/curl-ca-bundle.crt"
        #   }
        attr_writer :net_http

        private

        METHODS = {
          :head   => ::Net::HTTP::Head,
          :get    => ::Net::HTTP::Get,
          :post   => ::Net::HTTP::Post,
          :put    => ::Net::HTTP::Put,
          :delete => ::Net::HTTP::Delete
        }

        def request method, uri, options = {}
          head = headers.dup
          head.update options[:head] if options[:head]
          head.delete_if { |_, value| value.nil? }
          uri = base_uri + uri

          query_params = "?"
          query_params += "#{CGI.escape 'appId'}=#{CGI.escape FlightStats.app_id.to_s}"
          query_params += "&#{CGI.escape 'appKey'}=#{CGI.escape FlightStats.app_key.to_s}"
          if options[:params] && !options[:params].empty?
            pairs = options[:params].map { |key, value|
              "#{CGI.escape key.to_s}=#{CGI.escape value.to_s}"
            }
            query_params += "&#{pairs.join '&'}"
          end
          uri += query_params

          request = METHODS[method].new uri.request_uri, head
          if options[:body]
            request['Content-Type'] = content_type
            request.body = options[:body]
          end
          if options[:etag]
            request['If-None-Match'] = options[:etag]
          end
          if options[:format]
            request['Accept'] = FORMATS[options[:format]]
          end
          if options[:locale]
            request['Accept-Language'] = options[:locale]
          end
          http = ::Net::HTTP.new uri.host, uri.port
          http.use_ssl = uri.scheme == 'https'
          net_http.each_pair { |key, value| http.send "#{key}=", value }

          if FlightStats.logger
            FlightStats.log :info, "===> %s %s" % [request.method, uri]
            headers = request.to_hash
            headers['authorization'] &&= ['Basic [FILTERED]']
            FlightStats.log :debug, headers.inspect
            if request.body && !request.body.empty?
              FlightStats.log :debug, request.body
            end
            start_time = Time.now
          end

          response = http.start { http.request request }
          code = response.code.to_i

          json = (JSON.parse(response.body) if response && !response.body.empty?)
          if json and json['error'] and json['error']['httpStatusCode']
            code = json['error']['httpStatusCode'].to_i
          end

          if FlightStats.logger
            latency = (Time.now - start_time) * 1_000
            level = case code
              when 200...300 then :info
              when 300...400 then :warn
              when 400...500 then :error
              else                :fatal
            end
            FlightStats.log level, "<=== %d %s (%.1fms)" % [
              code,
              response.class.name[9, response.class.name.length].gsub(
                /([a-z])([A-Z])/, '\1 \2'
              ),
              latency
            ]
            FlightStats.log :debug, response.to_hash.inspect
            FlightStats.log :debug, response.body if response.body
          end

          case code
            when 200...300 then response
            else                raise ERRORS[code].new request, response
          end
        end
      end
    end

    extend Net::HTTPAdapter
  end
end