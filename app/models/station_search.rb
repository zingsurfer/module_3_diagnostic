class StationSearch
  def initialize(zip_code)
    @zip_code = zip_code
  end

  def stations
    data = service.stations_by_distance
    data[:fuel_stations].map do |station_data|
      Station.new(station_data)
    end


    # https://developer.nrel.gov/api/alt-fuel-stations/v1/nearest.json?location=80203&fuel_type=ELEC, LPG&limit=10&api_key=ENV["nrel_api_key"]
    conn = Faraday.new(url: "https://developer.nrel.gov") do |faraday|
      faraday.params["location"] = "80203"
      faraday.params["fuel_type"] = "ELEC, LPG"
      faraday.params["limit"] = 10
      faraday.params["api_key"] = ENV["nrel_api_key"]
      faraday.adapter Faraday.default_adapter
    end

    response = conn.get("/api/alt-fuel-stations/v1/nearest.json")
    data = JSON.parse(response.body, symbolize_names: true)

    data[:fuel_stations].map do |station_data|
      Station.new(station_data)
    end
  end

  def service
    NrelService.new(@zip_code)
  end 
end
