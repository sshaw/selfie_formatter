require "minitest"
require "selfie"

module Selfie
  class Minitest < Minitest::AbstractReporter
    def initialize(options)
      @selfie = Main.new(options[:io], options)
      @output = options[:io]
      @failed = {}
      @skipped = {}
    end

    def start
      @selfie.start
    end

    # result is a:
    # http://docs.seattlerb.org/minitest/Minitest/Runnable.html
    def record(result)
      case result.result_code
      when "S"
        path = @selfie.pending
        @skipped[path] = result if path
      when "F"
        path = @selfie.failed
        @failed[path] = result if path
      when "E"
        path = @selfie.failed
        @failed[path] = result if path
      else
        @selfie.passed
      end
    end

    def report
      @selfie.stop
    end

    def passed?
      @failed.empty?
    end
  end
end
