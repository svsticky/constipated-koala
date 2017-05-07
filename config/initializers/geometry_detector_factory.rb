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
