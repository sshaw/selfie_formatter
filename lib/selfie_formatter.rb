require "selfie/rspec"

if Selfie.supported_terminal?
  SelfieFormatter = Selfie::RSpec
else
  require "rspec/core/formatters"

  SelfieFormatter = Class.new(RSpec::Core::Formatters::ProgressFormatter) do
    # We output the warning twice: once for those will slow specs and another for those with fast
    def start(n)
      super
      output_warning
    end

    def dump_summary(summary)
      output_warning
      super
    end

    # Defined just to meet Selfie::Formatter registration requirements below
    def stop(n)
      super if defined?(super) # For forward compatibility :)
    end

    private

    def output_warning
      warn <<WARNING

SelfieFormatter Warning:

Unsupported terminal. You must use iTerm2 >= v3.0.
Since your terminal is not supported, the progress formatter was used in place of the SelfieFormatter.

WARNING
    end
  end
end

RSpec::Core::Formatters.register SelfieFormatter, :dump_summary, :dump_failures, :dump_pending, :close, :example_passed, :example_failed, :example_pending, :start, :stop
