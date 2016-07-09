require "fileutils"
require "mini_magick"

module Selfie
  class Main
    DEFAULT_COLUMNS = 80

    def initialize(output, options = {})
      raise ArgumentError, "can only render to a terminal" unless output.tty?

      @output = output
      @options = options
      @cursor = Cursor.new(@output)
      @camera = Camera.new(photo_dir(options[:save_to]))

      @columns = `stty size 2>/dev/null`.split(" ").last.to_i
      @columns = DEFAULT_COLUMNS if @columns == 0

      @image_offset = 1
      @spec_count = 0

      @main_img_height = nil
      @main_img_width = nil
    end

    def start
      @camera.on
      @cursor.hide
      @cursor.clear_screen
      @cursor.move_to(0, 0)
    end

    def stop
      @camera.off

      # Make sure we move down past the "film strip" before the summary is printed
      pos = @cursor.position
      if pos && pos[1] != 1
        @cursor.down(@main_img_height)
      end

      # TODO: keep this here?
      @output << "\n\n"
      @cursor.show
    end

    def passed
      image = capture("green")
      return unless image
      display_progess(image)
      image
    end

    def failed
      image = capture("red")
      return unless image
      display_progess(image)
      image
    end

    def pending
      image = capture("yellow")
      return unless image
      display_progess(image)
      image
    end

    private

    def photo_dir(root)
      path = File.join(root || File.join(Dir.pwd, "selfies"), Time.now.strftime("%Y-%m-%d-%H%M%S"))
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
      image = MiniMagick::Image.new(path)
      image.combine_options do |i|
        i.resize "250x250>"
        i.border "4x4"
        i.bordercolor color
        i.pointsize "26"
        i.weight "bold"
        i.undercolor "white"
        i.annotate "+4+28", @spec_count.to_s
      end
    rescue MiniMagick::Error => e
      raise Error, "image transformation failed: #{e}"
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
      @image_offset += 1
      if @image_offset * @main_img_width <= @columns
        @cursor.up(@main_img_height)
      else
        @image_offset = 1
        @output << "\n"
      end
    end

  end
end
