require "selfie/camera"
require "selfie/cursor"
require "selfie/main"
require "selfie/iterm2/image"

module Selfie
  Error = Class.new(StandardError)

  def self.supported_terminal?
    v = ENV["TERM_PROGRAM_VERSION"]
    !!(v && ENV["TERM_PROGRAM"] == "iTerm.app" && v.split(".").first.to_i >= 3)
  end
end
