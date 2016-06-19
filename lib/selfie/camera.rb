module Selfie
  class Camera
    CAPTURE_COMMAND = File.expand_path("../../imagesnap", __FILE__) << " -qw 0.8 -t 0.2"

    def initialize(outdir, options = {})
      @outdir = outdir
      @pid = nil
    end

    # The camera interface we'd like to have (and may at some point).
    # Until then, we fake it.
    def on
      return false if @pid

      # TODO: signals
      begin
        @pid = spawn(CAPTURE_COMMAND, :chdir => @outdir, [:out, :err] => File::NULL)
      rescue SystemCallError => e
        raise Error, "cannot spawn photo capture process: #{e}"
      end

      # Wait for camera to warm up, -w option is not enough :(
      sleep 2.5

      true
    end

    def off
      return false unless @pid

      begin
        Process.kill("TERM", @pid)
        Process.wait(@pid)
      rescue Errno::ESRCH, Errno::ECHILD
        # kill, wait cannot find pid
      end

      @pid = nil
      true
    end

    def capture
      sleep 0.2
      Dir[ File.join(@outdir, "snapshot-*.jpg") ].last
    end
  end
end
