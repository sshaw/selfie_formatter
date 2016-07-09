require "selfie/minitest"

module Minitest
  def self.plugin_selfie_options(opts, options)
    opts.on "-s", "--selfie", "Selfie. Takes photos of you while your tests run." do
      options[:selfie] = true
    end
  end

  def self.plugin_selfie_init(options)
    return unless options[:selfie]

    reporter.reporters.reject! { |o| o.is_a?(ProgressReporter) }
    reporter << Selfie::Minitest.new(options)
  end
end
