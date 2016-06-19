require "tty-cursor"

module Selfie
  class Cursor
    include TTY::Cursor

    def initialize(output)
      raise ArgumentError, "output must be a terminal" unless output.tty?
      @output = output
    end

    %w[up down forward back].each do |name|
      define_method(name) { |n| @output << super(n) }
    end

    %w[hide show].each do |name|
      # Explicitly calling super with 0 args is required
      define_method(name) { @output << super() }
    end

    # Calculates how many columns and rows the code in the given block moved the cursor
    def distance
      raise ArgumentError, "block required" unless block_given?

      beg_pos = position
      yield
      end_pos = position
      return unless end_pos && beg_pos

      # width, height
      [ end_pos[1] - beg_pos[1], end_pos[0] - beg_pos[0] ]
    end

    def position
      # TODO: save and restore original settings
      # TODO: use terminos instead?
      `stty -echo -icanon -cread`
      @output << current

      position = ""
      while ch = $stdin.getc
        position << ch
        break if ch == "R"
      end

      return unless position =~ %r|\[(\d+)\;(\d+)|

      [ $1.to_i, $2.to_i ]
    ensure
      # TODO: restore if killed..?
      `stty echo icanon cread`
    end
  end
end
