class TapController < UIViewController
  include BW::KVO

  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.whiteColor
    self.title = "Taps Aff"

    options_button = UIBarButtonItem.alloc.initWithTitle("Options", style: UIBarButtonItemStylePlain, target:self, action:'options')
    self.navigationItem.rightBarButtonItem = options_button

    @weather = Weather.new
 
    observe(@weather, :fetch_completed) do |old_value, new_value|
      if new_value == true 
        clear_views_and_draw
      end
    end
  end

  def viewWillAppear animated
    super
    @weather.calculate_if_taps_needed
    if @weather.fetch_completed
      clear_views_and_draw
    end
  end

  def viewDidAppear animated
    @weather.start_geolocation
  end

  def options
     options_controller = OptionsController.alloc.initWithNibName(nil, bundle: nil)
     self.navigationController.pushViewController(options_controller, animated: true)
  end
 
  private 
  def clear_views_and_draw
    self.view.subviews.each {|sv| sv.removeFromSuperview}
    add_tap_status 
    add_location_and_temperature
    add_refresh_button
  end

  def add_tap_status
    taps_needed = @weather.taps_needed
    label = UILabel.alloc.initWithFrame(CGRectZero)

    if taps_needed
      label.textColor = UIColor.blueColor
      label.text = "Taps Oan"
      imageName = "Cloud.png"
    else
      label.textColor = UIColor.redColor
      label.text = "Taps Aff"
      imageName = "Sun.png"
    end

    label.font = UIFont.fontWithName('Helvetica-Bold', size: 55)
    label.sizeToFit
    height = (self.view.frame.size.height / 100) * 10
    label.center = CGPointMake(self.view.frame.size.width / 2, height)
    self.view.addSubview label
    
    image = UIImageView.alloc.initWithImage(UIImage.imageNamed(imageName))
    image.sizeToFit
    height = (self.view.frame.size.height / 100) * 43 
    image.center = CGPointMake(self.view.frame.size.width / 2, height)
    self.view.addSubview image
  end

  def add_location_and_temperature
    location = @weather.location
    temperature = @weather.temperature

    if location
      location_label = UILabel.alloc.initWithFrame(CGRectZero)
      location_label.font = UIFont.fontWithName('Helvetica', size: 20)
      location_label.text = "Location: #{location}"
      location_label.sizeToFit
      height = (self.view.frame.size.height / 100) * 75 
      location_label.center = CGPointMake(self.view.frame.size.width / 2, height)
      self.view.addSubview location_label
    end
   
    if temperature 
      temperature_label = UILabel.alloc.initWithFrame(CGRectZero)
      temperature_label.font = UIFont.fontWithName('Helvetica', size: 20)
      temperature_label.text = "Temperature: #{temperature} °C"
      temperature_label.sizeToFit
      height = (self.view.frame.size.height / 100) * 83
      temperature_label.center = CGPointMake(self.view.frame.size.width / 2, height)
      self.view.addSubview temperature_label
    end
  end

  def add_refresh_button
    refresh_button = UIButton.buttonWithType UIButtonTypeRoundedRect
    refresh_button.setTitle "Refresh", forState: UIControlStateNormal 
    refresh_button.sizeToFit
    height = (self.view.frame.size.height / 100) * 93
    refresh_button.center = CGPointMake(self.view.frame.size.width / 2, height)
    self.view.addSubview refresh_button

    refresh_button.when(UIControlEventTouchUpInside) do
      puts 'touched'
      @weather.update_from_server
    end
  end
end
