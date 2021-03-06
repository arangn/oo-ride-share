require_relative 'spec_helper'

describe "Trip class" do

  describe "duration" do
    before do
      @trip_data = {
        start_time: Time.new(2018, 8, 28, 10, 0, 0),
        end_time: Time.new(2018, 8, 28, 11, 0, 0),
        id: 8,
        passenger: RideShare::User.new(id: 1,
          name: "Ada",
          phone: "412-432-7640"),
          cost: 23.45,
          rating: 3
        }
      end
      it "calculates duration of trip in seconds" do
        @trip = RideShare::Trip.new(@trip_data)
        expect(@trip.trip_duration).must_equal 3600
      end
      it "raises ArgumentError for an invalid end time" do
        @trip_data = {
          start_time: Time.new(2018, 8, 28, 14, 0, 0),
          end_time: Time.new(2018, 8, 28, 11, 0, 0),
          id: 8,
          passenger: RideShare::User.new(id: 1,
                                         name: "Ada",
                                         phone: "412-432-7640"),
          cost: 23.45,
          rating: 3
        }
        expect{ RideShare::Trip.new(@trip_data) }.must_raise ArgumentError
      end

    end

  describe "initialize" do
    before do
      start_time = Time.parse('2015-05-20T12:14:00+00:00')
      end_time = start_time + 25 * 60 # 25 minutes
      @driver = RideShare::Driver.new(id: 54, name: "Rogers Bartell IV",
                                      vin: "1C9EVBRM0YBC564DZ")
      @trip_data = {
        id: 8,
        passenger: RideShare::User.new(id: 1,
                                       name: "Ada",
                                       phone: "412-432-7640"),
        start_time: start_time,
        end_time: end_time,
        cost: 23.45,
        rating: 3,
        driver: @driver
      }
      @trip = RideShare::Trip.new(@trip_data)
    end


    # it "calculates duration of trip in seconds" do
    #   @trip_data[:start_time] = Time.new(2018, 8, 28, 10, 0, 0)
    #   @trip_data[:end_time] = Time.new(2018, 8, 28, 11, 0, 0)
    #   @trip = RideShare::Trip.new(@trip_data)
    #   expect(@trip.trip_duration).must_equal 3600
    # end
    #
    it "is an instance of Time" do
      expect(@trip.start_time).must_be_kind_of Time
    end

    it "is an instance of Trip" do
      expect(@trip).must_be_kind_of RideShare::Trip
    end

    it "stores an instance of user" do
      expect(@trip.passenger).must_be_kind_of RideShare::User
    end

    it "stores an instance of driver" do
      # skip  # Unskip after wave 2
      expect(@trip.driver).must_be_kind_of RideShare::Driver
    end

    it "raises an error for an invalid rating" do
      [-3, 0, 6].each do |rating|
        @trip_data[:rating] = rating
        expect {
          RideShare::Trip.new(@trip_data)
        }.must_raise ArgumentError
      end
    end
  end
end
