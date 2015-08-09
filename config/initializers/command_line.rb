Cocaine::CommandLine.module_eval do

  def run(interpolations = {})
    output = ''
    @exit_status = nil

    begin
      full_command = command(interpolations)
      log("#{colored("Command")} :: #{full_command}")

      Rails.logger.debug full_command
      output = execute(full_command)

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
        "Here is the command output:\n",
        output
      ].join("\n")

      raise Cocaine::ExitStatusError, message
    end
    output
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

  def log(text)
    Rails.logger.debug text
    @logger.info(text) if @logger
  end
end
