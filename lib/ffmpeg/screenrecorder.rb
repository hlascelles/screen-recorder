require 'streamio-ffmpeg'
require 'os'

module FFMPEG
  class Screenrecorder
    attr_reader :opts, :output

    def initialize(opts = {})
      @opts       = default_config.merge opts
      @output     = opts[:output]
      @video_file = nil
      @process    = nil
      init_logger(opts[:logging_level])
    end

    def opts=(new_opts)
      @opts   = default_config.merge new_opts
      @output = opts[:output]
      init_logger(opts[:logging_level]) if FFMPEG.logger.level != opts[:logging_level]
    end

    def start
      FFMPEG.logger.debug "Starting: #{command}"
      @video_file = nil # New file
      @process    = start_ffmpeg
      FFMPEG.logger.info 'Recording...'
    end

    def stop
      FFMPEG.logger.debug 'Stopping ffmpeg.exe...'
      # msg = Process.kill('INT', @process_id)
      # Process.detach(@process_id)
      kill_ffmpeg
      FFMPEG.logger.debug 'Stopped ffmpeg.exe'
      FFMPEG.logger.info 'Recording complete.'
    end

    # def inputs(application)
    #   FFMPEG.logger.debug "Retrieving available windows from: #{application}"
    #   available_inputs_by application
    # end

    def video_file
      @video_file ||= Movie.new(output)
    end

    private

    def default_config
      { input:     'desktop',
        framerate: 15,
        device:    'gdigrab',
        log:       'ffmpeg_recorder_log.txt' }
    end

    def start_ffmpeg
      IO.popen(command, 'r+')
      # spawn(command)
      # pid = `powershell (Get-Process ffmpeg).id`.to_i
      # raise 'ffmpeg failed to start.' if pid.zero?
      # pid = Process.spawn(command, :new_pgroup => true)
      # pid = `powershell (Get-Process ffmpeg).id`.to_i
      # raise 'ffmpeg failed to start.' if pid.zero?
      # pid
    end

    def kill_ffmpeg
      @process.puts 'q' # Gracefully exit ffmpeg
      sleep(1.0)
      @process.close_write # Close IO
    end

    def init_logger(level)
      FFMPEG.logger.progname  = 'FFMPEG::Recorder'
      FFMPEG.logger.level     = level
      FFMPEG.logger.formatter = proc do |severity, time, progname, msg|
        "#{time.strftime('%F %T')} #{progname} - #{severity} - #{msg}\n"
      end
      FFMPEG.logger.debug "Logger initialized."
    end

    def command
      "#{FFMPEG.ffmpeg_binary} -y " \
      "#{extra_opts}" \
      "-f #{opts[:device]} " \
      "-framerate #{opts[:framerate]} " \
      "-i #{opts[:input]} " \
      "#{opts[:output]} " \
      "2> #{opts[:log]}"
    end

    def extra_opts
      return nil unless opts[:extra_opts]
      raise ':extra_opts cannot be empty.' if opts[:extra_opts].empty?

      arr = []
      opts[:extra_opts].each { |k, v|
        arr.push "-#{k} #{v}"
      }
      ' ' + arr.join(' ') + ' '
    end

    # def available_inputs_by(application)
    #   `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
    #     .split("\n")
    #     .reject { |title| title == 'Window Title: N/A' }
    # end
    #
    # def input
    #   return opts[:input] if opts[:input] == 'desktop'
    #   %Q(title="#{opts[:input].gsub('Window Title: ', '')}")
    # end
  end # class Recorder
end # module FFMPEG
