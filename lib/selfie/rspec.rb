require "rspec"
# This is needed by the Reporter. RSpec doesn't require it.
require "rspec/core/formatters/console_codes"
require "selfie"

module Selfie
  class RSpec
    def self.image_dimensions
      @image_dimensions ||= RSpec.configuration.image_dimensions || IMAGE_DIMENSIONS
    end

    def self.output_directory
      @output_directory ||= RSpec.configuration.selfie_output_directory || File.join(Dir.pwd, "selfies")
    end

    def self.output_directory=(path)
      @output_directory = path
    end

    def initialize(output)
      @output = output
      @failed = {}
      @pending = {}
    end

    def start(notification)
      options =
      @test = Main.new(@output)
      @test.start
    end

    def stop(notification)
      @test.stop
    end

    def close(n)
      #@output << "\n\n"
      @output.flush
    end

    def example_passed(notification)
      @test.passed
    end

    def example_failed(notification)
      image = @test.failed
      @failed[notification.example] = image if image
    end

    def example_pending(notification)
      image = @test.pending
      @pending[notification.example] = image if image
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
  end
end

RSpec.configuration.add_setting :selfie_output_directory
