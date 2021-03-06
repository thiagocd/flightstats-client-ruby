module FlightStats
  module Version
    MAJOR   = 0
    MINOR   = 5
    PATCH   = 2
    PRE     = nil

    VERSION = [MAJOR, MINOR, PATCH, PRE].compact.join('.').freeze

    class << self
      def inspect
        VERSION.dup
      end
      alias to_s inspect
    end
  end
end
