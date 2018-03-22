require 'spec_helper'
require 'spec_mock_helper'

describe FlightStats::Alert do
  before(:each) do
    WebMock.reset!
  end

  describe "by_flight_id and arrival airport" do
    it "maps the json and store the hash in data " do
      stub_api_request :get, FlightStats::Alert.base_path, 'alert'
      alert = FlightStats::Alert.by_arrival 'AF', 6127, 'ORY', 2015, 02, 06
      alert.should be_an_instance_of FlightStats::Alert
      alert.data.should eq data_from_response('alert')
    end
  end

  describe "by_flight_id and departure airport" do
    it "maps the json and store the hash in data " do
      stub_api_request :get, FlightStats::Alert.base_path, 'alert'
      alert = FlightStats::Alert.by_arrival 'AF', 6127, 'TLS', 2015, 02, 06
      alert.should be_an_instance_of FlightStats::Alert
      alert.data.should eq data_from_response('alert')
    end
  end
end
