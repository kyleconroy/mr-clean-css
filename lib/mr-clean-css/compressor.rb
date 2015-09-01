class MrCleanCSS::Compressor

  attr_reader :last_result

  def initialize(options = {})
    @js_options = options
  end

  def compress(stream_or_string)
    result = minifier.minify(stream_or_string.to_s)
    @last_result = result
    result[:min]
  end

  def minifier
    @minifier ||= MrCleanCSS::Minifier.new(@js_options)
  end
end
