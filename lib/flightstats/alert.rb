require 'json'
module FlightStats
  class Alert < OpenStruct

    @@base_path = "/flex/alerts/rest/v1/json"

    class << self
      def by_arrival(carrier, flight_number, arrival_airport, year, month, day, options = {})
        from_response API.get("#{base_path}/create/#{carrier}/#{flight_number}/to/#{arrival_airport}/arriving/#{year}/#{month}/#{day}",
                              required_params,
                              options), 'alert'
      end

      def by_departure(carrier, flight_number, departure_airport, year, month, day, options = {})
        from_response API.get("#{base_path}/create/#{carrier}/#{flight_number}/from/#{departure_airport}/departing/#{year}/#{month}/#{day}",
                              required_params,
                              options), 'alert'
      end

      def delete_by_id(id, options = {})
        from_response API.get("#{base_path}/delete/#{id}",
                              {},
                              options), 'alert'
      end

      def required_params
        {
          deliverTo: FlightStats.alert_deliveries,
          type: FlightStats.alert_type
        }
      end

      def base_path
        @@base_path
      end

      def from_response(response, fdf)
        parsed = JSON.parse(response.body, symbolize_names: true)
        with_data = parsed.merge(data: parsed)
        new(with_data)
      end
    end
  end
end
