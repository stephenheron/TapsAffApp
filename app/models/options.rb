class Options
  attr_accessor :taps_threshold

  def self.createNewOrCreateFromStorage
    defaults = NSUserDefaults.standardUserDefaults
    if options_as_data = defaults['saved_options']
      options = NSKeyedUnarchiver.unarchiveObjectWithData(options_as_data)
    else
      options = Options.new
    end
    return options  
  end

  def save
    defaults = NSUserDefaults.standardUserDefaults
    options_as_data = NSKeyedArchiver.archivedDataWithRootObject(self)
    defaults['saved_options'] = options_as_data
  end

  def initialize
    @taps_threshold = '20'
  end

  def initWithCoder(decoder)
    self.init
    self.taps_threshold = decoder.decodeObjectForKey("options_threshold")
    self
  end

  def encodeWithCoder(encoder)
    encoder.encodeObject(self.taps_threshold, forKey: "options_threshold")
  end
end
