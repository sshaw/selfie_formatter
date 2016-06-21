# This is needed by the Reporter. RSpec doesn't require it.
require "rspec/core/formatters/console_codes"

require "fileutils"
require "mini_magick"

require "selfie"

class SelfieFormatter
  include Selfie

  DEFAULT_COLUMNS = 80

  RSpec::Core::Formatters.register self, :dump_summary, :dump_failures, :dump_pending, :close, :example_passed, :example_failed, :example_pending, :start, :stop

  def self.output_directory
    @output_directory ||= RSpec.configuration.selfie_output_directory || File.join(Dir.pwd, "selfies")
  end

  def self.output_directory=(path)
    @output_directory = path
  end

  def initialize(output, options = {})
    raise ArgumentError, "can only render to a terminal" unless output.tty?

    @output  = output
    @options = options
    @cursor = Cursor.new(@output)
    @camera = Camera.new(photo_dir)

    @columns = `stty size 2>/dev/null`.split(" ").last.to_i
    @columns = DEFAULT_COLUMNS if @columns == 0

    @offset  = 1
    @spec_count = 0

    @failed = {}
    @pending = {}

    @main_img_height = nil
    @main_img_width = nil
  end

  def start(notification)
    @camera.on
    @cursor.hide
    @cursor.clear_screen
    @cursor.move_to(0, 0)
  end

  def stop(notification)
    @camera.off

    # Make sure we move down past the "film strip" before the summary is printed
    pos = @cursor.position
    if pos && pos[1] != 1
      @cursor.down(@main_img_height)
    end

    @output << "\n\n"
  end

  def close(n)
    @cursor.show
    @output.flush
  end

  def example_passed(notification)
    image = capture("green")
    display_progess(image) if image
  end

  def example_failed(notification)
    image = capture("red")
    return unless image

    @failed[notification.example] = image
    display_progess(image)
  end

  def example_pending(notification)
    image = capture("yellow")
    return unless image

    @pending[notification.example] = image
    display_progess(image)
  end

  def dump_pending(notification)
    if notification.pending_notifications.any?
      @output << "\nPending:\n"
      dump_notifications(notification.pending_notifications, @pending)
    end
  end

  def dump_failures(notification)
    if notification.failure_notifications.any?
      @output << "\nFailures:\n"
      dump_notifications(notification.failure_notifications, @failed)
    end
  end

  def dump_summary(summary)
    @output.puts summary.fully_formatted
  end

  private

  def dump_notifications(notifications, images)
    notifications.each_with_index do |notification, i|
      notice = notification.fully_formatted(i + 1)
      if images[notification.example]
        # Replace the example's number with its photo
        notice.sub!(%r|\A\s*\d+\)\s+(.+)$|, "\n%s\\1\n" % images[notification.example].to_s(:width => 12))
      end

      @output << notice
    end
  end

  def photo_dir
    path = File.join(SelfieFormatter.output_directory, Time.now.strftime("%Y-%m-%d-%H%M%S"))
    FileUtils.mkdir_p(path)
    path
  end

  def capture(color)
    @spec_count += 1

    path = @camera.capture
    return unless path

    transform(path, color)
    ITerm2::Image.new(path)
  end

  def transform(path, color)
    # TODO: options
    # TODO: put number in a white box
    image = MiniMagick::Image.new(path)
    image.combine_options do |i|
      i.resize "250x250>"
      i.border "4x4"
      i.bordercolor color
      i.pointsize '26'
      i.weight 'Bold'
      # for 26 point
      # count isn't available on Notification -of something?!
      i.annotate "+10+30", @spec_count.to_s
      # for 32 point
      #i.annotate "+15+40", "#1000"
    end
  end

  def display_progess(image)
    # TODO: subclass?
    # if SelfieFormatter.film_strip?
    film_strip_formatter(image)
  end

  def film_strip_formatter(image)
    output_image(image)
    adjust_cursor
  end

  def output_image(image)
    str = image.to_s
    if @main_img_height && @main_img_width
      @output << str
    else
      @main_img_width, @main_img_height = @cursor.distance { @output << str }
      raise Error, "formatting failed: cannot determine cursor position" unless @main_img_width && @main_img_height
    end
  end

  def adjust_cursor
    # Check if the next image fits on the current row
    @offset += 1
    if @offset * @main_img_width <= @columns
      @cursor.up(@main_img_height)
    else
      @offset = 1
      @output << "\n"
    end
  end
end

RSpec.configuration.add_setting :selfie_output_directory
