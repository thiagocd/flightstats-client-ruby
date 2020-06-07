module FlightStats
  class ScheduledFlight < Resource
    attr_accessor :carrier_fs_code,
                  :flight_number,
                  :departure_airport_fs_code,
                  :departure_airport_iata_code,
                  :departure_airport_icao_code,
                  :arrival_airport_fs_code,
                  :arrival_airport_iata_code,
                  :arrival_airport_icao_code,
                  :stops,
                  :departure_terminal,
                  :arrival_terminal,
                  :departure_time,
                  :arrival_time,
                  :flight_equipment_iata_code,
                  :is_codeshare,
                  :is_wetlease,
                  :codeshares,
                  :service_type,
                  :service_classes,
                  :traffic_restrictions,
                  :reference_code,
                  :airports,
                  :airline_icao_code,
                  :airline_iata_code,
                  :airline_name

    @@base_path = "/flex/schedules/rest/v1/json"

    class << self
      def by_carrier_and_flight_number_departing_on(carrier_fs_code, flight_number, year, month, day, params = {}, options = {})
        response = API.get("#{base_path}/flight/#{carrier_fs_code}/#{flight_number}/departing/#{year}/#{month}/#{day}", params, options)
        parse_response(response)
      end

      def by_carrier_and_flight_number_arriving_on(carrier_fs_code, flight_number, year, month, day, params = {}, options = {})
        response = API.get("#{base_path}/flight/#{carrier_fs_code}/#{flight_number}/arriving/#{year}/#{month}/#{day}", params, options)
        parse_response(response)
      end

      def by_route_departing_on(departure_code, arrival_code, year, month, day, params = {}, options = {})
        response = API.get("#{base_path}/from/#{departure_code}/to/#{arrival_code}/departing/#{year}/#{month}/#{day}", params, options)
        parse_response(response)
      end

      def by_route_arriving_on(departure_code, arrival_code, year, month, day, params = {}, options = {})
        response = API.get("#{base_path}/from/#{departure_code}/to/#{arrival_code}/arriving/#{year}/#{month}/#{day}", params, options)
        parse_response(response)
      end

      def departing_from_airport_at_date_and_hour(departure_code, year, month, day, hour, params = {}, options = {})
        response = API.get("#{base_path}/from/#{departure_code}/departing/#{year}/#{month}/#{day}/#{hour}", params, options)
        parse_response(response)
      end

      def arriving_at_airport_at_date_and_hour(arrival_code, year, month, day, hour, params = {}, options = {})
        response = API.get("#{base_path}/to/#{arrival_code}/arriving/#{year}/#{month}/#{day}/#{hour}", params, options)
        parse_response(response)
      end

      def base_path
        @@base_path
      end

      def add_icao_and_iata_airport_code(response, scheduled_flights)
        appendix = from_response response, 'appendix'
        airports = appendix.airports
        scheduled_flights.each do |sf|
          departure_airport = airports.detect { |airport| airport.fs == sf.departure_airport_fs_code }
          sf.departure_airport_icao_code = departure_airport.icao
          sf.departure_airport_iata_code = departure_airport.iata
          arrival_airport = airports.detect { |airport| airport.fs == sf.arrival_airport_fs_code }
          sf.arrival_airport_icao_code = arrival_airport.icao
          sf.arrival_airport_iata_code = arrival_airport.iata
        end
        scheduled_flights
      end

      def add_airports_info(response, scheduled_flights)
        appendix = from_response response, 'appendix'
        airports = appendix.airports
        scheduled_flights.each do |sf|
          sf.airports = airports
        end
        scheduled_flights
      end

      def add_airline_info(response, scheduled_flights)
        appendix = from_response response, 'appendix'
        airlines = appendix.airlines
        scheduled_flights.each do |sf|
          airline = airlines.detect { |airline| airline.fs == sf.carrier_fs_code }
          sf.airline_name = airline.name
          sf.airline_icao_code = airline.icao
          sf.airline_iata_code = airline.iata
        end
        scheduled_flights
      end

      def parse_response(response)
        scheduled_flights = from_response response, 'scheduledFlights'
        add_icao_and_iata_airport_code(response, scheduled_flights)
        add_airline_info(response, scheduled_flights)
        add_airports_info(response, scheduled_flights)
      end
    end
  end
end
