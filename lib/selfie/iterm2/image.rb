require "base64"

module Selfie
  module ITerm2
    class Image
      attr :path

      def initialize(path, options = {})
        @path = path
        @options = options.dup
        @options[:inline] = 1
        @image = Base64.encode64(File.read(path))
      end

      def to_s(options = {})
        sprintf("%s1337;File=%s:%s%s", start_esc, format_options(options), @image, end_esc)
      end

      private

      def screen_tty?
        $stdout.tty? && ENV.include?("TERM") && ENV["TERM"].start_with?("screen")
      end

      # From imgls: https://raw.githubusercontent.com/gnachman/iTerm2/master/tests/imgls
      def start_esc
        @screen == true ? "\ePtmux;\e\e]" : "\e]"
      end

      def end_esc
        @screen == true ? "\a\e\\" : "\a"
      end
      # --

      def format_options(options)
        @options.merge(options).map do |name, value|
          if name == :preserve_aspect_ratio
            name  = "preserveAspectRatio"
            value = value == false ? 0 : 1
          end

          sprintf "%s=%s", name, value
        end.join(";")
      end
    end
  end
end
