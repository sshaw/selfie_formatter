require "selfie"

def supported_terminal?
  v = ENV["TERM_PROGRAM_VERSION"]
  !!(v && ENV["TERM_PROGRAM"] == "iTerm.app" && v.split(".").first.to_i >= 3)
end

if supported_terminal?
  SelfieFormatter = Selfie::Formatter
else
  require "rspec/core/formatters"

  SelfieFormatter = Class.new(RSpec::Core::Formatters::ProgressFormatter) do
    def dump_summary(summary)
      warn <<WARNING

SelfieFormatter Warning:

Unsupported terminal. You must use iTerm2 >= v3.0.
Since your terminal is not supported, the progress formatter was used in place of the SelfieFormatter.

WARNING

      super
    end

    # Defined just to meet Selfie::Formatter registration requirements below
    def stop(n)
      super if defined?(super) # For forward compatibility :)
    end
  end
end

RSpec::Core::Formatters.register SelfieFormatter, :dump_summary, :dump_failures, :dump_pending, :close, :example_passed, :example_failed, :example_pending, :start, :stop
