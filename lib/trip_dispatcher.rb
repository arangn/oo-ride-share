require 'csv'
require 'time'
require 'pry'

require_relative 'user'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(user_file = 'support/users.csv',
      trip_file = 'support/trips.csv',
      driver_file = 'support/drivers.csv')
      @passengers = load_users(user_file)
      @drivers = load_drivers(driver_file)
      @trips = load_trips(trip_file)
    end

    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end
      return users
    end

    def load_drivers(filename)
      driver_data = CSV.open(filename, 'r', headers: true, header_converters: :symbol)

      return driver_data.map do |each_driver|
        user = find_passenger(each_driver[:id].to_i)
        # binding.pry
        driver = {
          id: each_driver[:id].to_i,
          trips: user.trips,
          vin: each_driver[:vin],
          status: each_driver[:status].to_sym,
          name: user.name,
          phone: user.phone_number
        }

        Driver.new(driver)
      end

    end

    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true,
        header_converters: :symbol)

        trip_data.each do |raw_trip|
          passenger = find_passenger(raw_trip[:passenger_id].to_i)
          driver = find_driver(raw_trip[:driver_id].to_i)
          raw_trip[:start_time] = Time.parse(raw_trip[:start_time])
          raw_trip[:end_time] = Time.parse(raw_trip[:end_time])
          parsed_trip = {
            id: raw_trip[:id].to_i,
            passenger: passenger,
            start_time: raw_trip[:start_time],
            end_time: raw_trip[:end_time],
            cost: raw_trip[:cost].to_f,
            rating: raw_trip[:rating].to_i,
            driver: driver
          }

          trip = Trip.new(parsed_trip)
          passenger.add_trip(trip)
          driver.add_driven_trip(trip)
          trips << trip

        end
        return trips
      end

      def find_passenger(id)
        check_id(id)
        return @passengers.find { |passenger| passenger.id == id }
      end

      def find_driver(id)
        check_id(id)
        return @drivers.find { |driver| driver.id == id }
      end

      def inspect
        return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
        #{trips.count} trips, \
        #{drivers.count} drivers, \
        #{passengers.count} passengers>"
      end

      def check_id(id)
        raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})" if id.nil? || id <= 0
      end

      def request_trip(user_id)
        chosen_driver = assign_driver(user_id)
        passenger = find_passenger(user_id)

        valid_trip_id = [1..1000].select
        @trips.each do |trip|
          if trip.id == valid_trip_id
            raise ArgumentError, "ID already exists"
          end
        end

        trip = RideShare::Trip.new(id: valid_trip_id, driver: chosen_driver, passenger: passenger, start_time: Time.now, end_time: nil, cost: nil, rating: nil)

        chosen_driver.add_driven_trip(trip)
        passenger.add_trip(trip)
        @trips << trip
        return trip
      end

      def assign_driver(passenger_id)
        # iterates through the drivers to select and return available drivers and drivers who are not driving themselves
        available_drivers = @drivers.select do |driver|
          if driver.status == :AVAILABLE && driver.id != passenger_id
            driver
          end
        end

        # iterates through the available_drivers to see if there is a driver that has not given any trips.
        chosen_driver = available_drivers.find do |driver|
          driver.driven_trips.empty?
        end

        # if there hasn't been a driver that hasn't given any trips, then this iterates through available drivers and selects the driver who's trip ended the longest time ago.
        if chosen_driver.nil?
          furthest_date = Time.now
          available_drivers.each do |driver|
            # This assumes that driven_trips are in chronological order
            end_time = driver.driven_trips.last.end_time
            if end_time < furthest_date
              end_time = furthest_date # sets new end time
              chosen_driver = driver # assigns that driver as chosen driver
            end
          end
        end

        # if there are no available drivers
        if chosen_driver.nil?
          raise ArgumentError, "No drivers available"
        end

        # if there is an available driver, changes their status
        chosen_driver.status = :UNAVAILABLE
        return chosen_driver
      end
    end
  end
