# TODO resize images on amazon
Paperclip::GeometryDetector.module_eval do
  private

  def geometry_string
    begin
      orientation = Paperclip.options[:use_exif_orientation] ? "%[exif:orientation]" : "1"

      Rails.logger.debug "file: #{path}[0]"

      response = Paperclip.run(
        "identify",
        "-format '%wx%h,#{orientation}' :file", {
          :file => "#{path}[0]"
        }, {
          :swallow_stderr => true
        }
      )

      Rails.logger.debug "output #{response.inspect}"
      return response
    rescue Cocaine::ExitStatusError => e
      Rails.logger.fatal "ExitStatus #{e.inspect}"
      ""
    rescue Cocaine::CommandNotFoundError => e
      Rails.logger.fatal "CommandNotFound #{e.inspect}"
      raise_because_imagemagick_missing
    end
  end
end

# TODO image resizing on amazon
Cocaine::CommandLine.module_eval do

  def run(interpolations = {})
    @exit_status = nil
    begin
      full_command = command(interpolations)
      log("#{colored("Command")} :: #{full_command}")
      @output = execute(full_command)
    rescue Errno::ENOENT => e
      raise Cocaine::CommandNotFoundError, e.message
    ensure
      @exit_status = $?.respond_to?(:exitstatus) ? $?.exitstatus : 0
    end

    if @exit_status == 127
      raise Cocaine::CommandNotFoundError
    end

    unless @expected_outcodes.include?(@exit_status)
      message = [
        "Command '#{full_command}' returned #{@exit_status}. Expected #{@expected_outcodes.join(", ")}",
        "Here is the command output: STDOUT:\n", command_output,
        "\nSTDERR:\n", command_error_output
      ].join("\n")
      raise Cocaine::ExitStatusError, message
    end

    command_output
  end

  private

  def interpolate(pattern, interpolations)
    interpolations = stringify_keys(interpolations)

    pattern.gsub(/:\{?(\w+)\b\}?/) do |match|

      key = match.tr(":{}", "")

      if interpolations.key?(key)
        "'#{interpolations[key]}'"
      else
        match
      end
    end
  end
end
