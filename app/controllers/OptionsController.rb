class OptionsController < UIViewController

  def loadView
    views = NSBundle.mainBundle.loadNibNamed 'options', owner:self, options:nil
    self.view = views[0]
  end

  def viewDidLoad
    super
    @options = Options.createNewOrCreateFromStorage

    @taps_threshold_textbox = self.view.viewWithTag 1
    @save_button = self.view.viewWithTag 2

    @taps_threshold_textbox.text = @options.taps_threshold

    @save_button.when(UIControlEventTouchUpInside) do
      @options.taps_threshold = @taps_threshold_textbox.text
      @options.save
      self.navigationController.popViewControllerAnimated true
    end

    self.view.backgroundColor = UIColor.whiteColor
    self.title = "Options"

  end
end
