#:nodoc:
class GhostscriptPreviewer < ActiveStorage::Previewer
  class << self
    def accept?(blob)
      blob.content_type == 'application/pdf' && ghostscript_exists?
    end

    def ghostscript_path
      ActiveStorage.paths[:ghostscript] || 'gs'
    end

    def ghostscript_exists?
      return @ghostscript_exists unless @ghostscript_exists.nil?

      system(ghostscript_path, '--version', out: File::NULL, err: File::NULL)
      @ghostscript_exists = $?.exitstatus == 0
    end
  end

  def preview
    download_blob_to_tempfile do |input|
      Rails.logger.debug(blob.filename.base)

      draw_image_from_pdf(input) do |output|
        yield(io: output, filename: "#{ blob.filename.base }.png", content_type: "image/png")
      end
    end
  end

  private

  def draw_image_from_pdf(input, &block)
    dst = Tempfile.new("#{ blob.filename.base }.png")
    dst.binmode

    system(self.class.ghostscript_path, '-dNOPAUSE', '-dSAFER', '-dBATCH', '-sDEVICE=pngalpha', '-r144', '-dUseCIEColor', "-sOutputFile=#{ dst.path }", input.path)

    draw('cat', dst.path, &block)
    File.delete(dst)
  end
end
