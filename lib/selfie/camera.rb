module Selfie
  class Camera
    CAPTURE_COMMAND = File.expand_path("../../imagesnap", __FILE__) << " -qw 0.8 -t 0.2"

    def initialize(outdir, options = {})
      @outdir = outdir
      @glob = File.join(@outdir, "snapshot-*.jpg")
      @captured = []
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

      # final cleanup
      FileUtils.rm_f(Dir[@glob] - @captured)

      @pid = nil
      true
    end

    # Some hacks to make it seem like capture() takes a picture
    # without accumulating a ton of unused images.
    def capture
      sleep 0.2

      images = Dir[@glob]
      return if images.none? || images.last == @captured.last

      @captured << images.last
      FileUtils.rm_f(images - @captured)

      @captured.last
    end
  end
end
