class Weather
  include BW::KVO

  attr_accessor :location
  attr_accessor :temperature
  attr_accessor :taps_needed
  attr_accessor :lat
  attr_accessor :long
  attr_accessor :fetch_completed

  def initialize
    self.location = ''
    self.temperature = ''
    self.taps_needed = nil
    self.lat = nil
    self.long = nil
    self.fetch_completed = false
    
    add_temperature_changed_observer
  end

  def start_geolocation
    watch_for_lat_long_changes
    add_lat_long_changed_observer
  end

  def update_from_server
    data = {:lat => self.lat, :long => self.long}
    BW::HTTP.get("http://localhost:8000/weather", {payload: data}) do |response|
      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        self.location = json['location']
        self.temperature = json['temperature']
      else
        App.alert('Somthing went wrong when attempting to get the weather')
      end
    end
  end

  def calculate_if_taps_needed
    options = Options.createNewOrCreateFromStorage
    if temperature < options.taps_threshold 
      self.taps_needed = true
    else
      self.taps_needed = false
    end
  end

  private
  
  def add_temperature_changed_observer
    observe(self, :temperature) do |old_temp, new_temp|
      calculate_if_taps_needed
      # fetch_completed used to fire events 
      self.fetch_completed = true
    end
  end

  def add_lat_long_changed_observer
    observe(self, :long) do |old_long, new_long|
      update_from_server
    end
  end

  def watch_for_lat_long_changes
    BW::Location.get(distance_filter: 100) do |result|
      if result[:error]
        App.alert("Sorry, but it looks like we could not get your location at this time")
      else
        lat = result[:to].coordinate.latitude
        long = result[:to].coordinate.longitude
        self.lat = lat
        self.long = long
      end 
    end
  end

end
