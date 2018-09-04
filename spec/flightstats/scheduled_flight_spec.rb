require 'spec_helper'
require 'spec_mock_helper'

describe FlightStats::ScheduledFlight do
  before(:each) do
    WebMock.reset!
  end

  describe "by_carrier_and_flight_number_departing_on" do
    it "must find flight flights" do
      stub_api_request :get, FlightStats::ScheduledFlight.base_path, 'scheduled_flights'
      flights = FlightStats::ScheduledFlight.by_carrier_and_flight_number_departing_on 'UA', '100', '2014', '07', '07'
      flight = flights.first
      flight.should be_an_instance_of FlightStats::ScheduledFlight
      flight.carrier_fs_code.should == 'UA'
      flight.arrival_airport_icao_code == 'KPDX'
      flight.arrival_airport_iata_code == 'PDX'
      flight.departure_airport_icao_code == 'KSFO'
      flight.departure_airport_iata_code == 'SFO'
    end
  end

  describe "by_carrier_and_flight_number_arriving_on" do
    it "must find flight flights" do
      stub_api_request :get, FlightStats::ScheduledFlight.base_path, 'scheduled_flights'
      flights = FlightStats::ScheduledFlight.by_carrier_and_flight_number_arriving_on 'UA', '100', '2014', '07', '07' 
      flight = flights.first
      flight.should be_an_instance_of FlightStats::ScheduledFlight
      flight.carrier_fs_code.should == 'UA'
      flight.arrival_airport_icao_code == 'KPDX'
      flight.arrival_airport_iata_code == 'PDX'
      flight.departure_airport_icao_code == 'KSFO'
      flight.departure_airport_iata_code == 'SFO'
    end
  end

  describe "by_route_departing_on" do
    it "must find flight flights" do
      stub_api_request :get, FlightStats::ScheduledFlight.base_path, 'scheduled_flights'
      flights = FlightStats::ScheduledFlight.by_route_departing_on 'SFO', 'PDX', '2014', '07', '07' 
      flight = flights.first
      flight.should be_an_instance_of FlightStats::ScheduledFlight
      flight.carrier_fs_code.should == 'UA'
      flight.arrival_airport_icao_code == 'KPDX'
      flight.arrival_airport_iata_code == 'PDX'
      flight.departure_airport_icao_code == 'KSFO'
      flight.departure_airport_iata_code == 'SFO'
      flight.airports.count == 2
    end
  end

  describe "by_route_arriving_on" do
    it "must find flight flights" do
      stub_api_request :get, FlightStats::ScheduledFlight.base_path, 'scheduled_flights'
      flights = FlightStats::ScheduledFlight.by_route_arriving_on 'SFO', 'PDX', '2014', '07', '07' 
      flights.first.should be_an_instance_of FlightStats::ScheduledFlight
      flights.first.carrier_fs_code.should == 'UA'
    end
  end

  describe "departing_from_airport_at_date_and_hour" do
    it "must find flight flights" do
      stub_api_request :get, FlightStats::ScheduledFlight.base_path, 'scheduled_flights'
      flights = FlightStats::ScheduledFlight.departing_from_airport_at_date_and_hour 'SFO', '2014', '07', '07', '18' 
      flights.first.should be_an_instance_of FlightStats::ScheduledFlight
      flights.first.carrier_fs_code.should == 'UA'
    end
  end

  describe "arriving_at_airport_at_date_and_hour" do
    it "must find flight flights" do
      stub_api_request :get, FlightStats::ScheduledFlight.base_path, 'scheduled_flights'
      flights = FlightStats::ScheduledFlight.arriving_at_airport_at_date_and_hour 'PDX', '2014', '07', '07', '20' 
      flights.first.should be_an_instance_of FlightStats::ScheduledFlight
      flights.first.carrier_fs_code.should == 'UA'
    end
  end
end