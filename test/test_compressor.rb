require 'test/unit'
require 'mr-clean-css'

class MrCleanCSS::TestCompressor < Test::Unit::TestCase

  def test_compression
    assert_equal('a{color:#7fff00}', compress('a { color: chartreuse; }'))
  end


  def test_option_to_keep_breaks
    # Confirm that breaks aren't kept by default
    parts = ['a{color:#7fff00}','b{font-weight:900}']
    assert_equal(
      parts.join,
      compress(parts.join("\n"))
    )

    # ... then confirm that breaks are kept when the option is set to true.
    parts = ['a{color:#7fff00}','b{font-weight:900}']
    assert_equal(
      parts.join("\n"),
      compress(parts.join("\n"), :keep_breaks => true)
    )
  end


  def test_local_import_processing
    local_path = 'test/bar.css'
    File.open(local_path, 'w') { |f|
      f << 'b { font-weight: 900; }'
    }
    assert_equal(
      'b{font-weight:900}a{color:#7fff00}',
      compress(%Q`
        @import url(#{local_path});

        a {
          color: chartreuse;
        }
      `)
    )
    File.unlink(local_path)
  end


  def test_remote_import_processing
    url = 'https://raw.githubusercontent.com/kyleconroy/mr-clean-css/master/test/foo.css'
    assert_equal(
      'a{color:#7fff00}',
      compress("@import url(#{url});")
    )
  end


  def test_url_rebasing
    local_import_path = 'test/bar.css'
    local_image_path = '../images/lenna.jpg'
    File.open(local_import_path, 'w') { |f|
      f << "div { background-image: url(#{local_image_path}); }"
    }
    assert_equal(
      'div{background-image:url(images/lenna.jpg)}',
      compress("@import url(#{local_import_path});")
    )
    File.unlink(local_import_path)
  end

  def test_processing_error
    c = MrCleanCSS::Compressor.new
    c.compress('@import(faksjdfka;lkasdf;asjdf')
    assert_equal(
      "\e[31mERROR\e[39m: Broken @import declaration of \"faksjdfka\"\n",
      c.last_result[:errors].first
    )
  end

  def compress(str, options = {})
    c = MrCleanCSS::Compressor.new(options)
    c.compress(str)
    if c.last_result[:errors].any?
      STDERR.puts(c.last_result[:errors].join("\n"))
    end
    if c.last_result[:warnings].any?
      STDERR.puts(c.last_result[:errors].join("\n"))
    end
    c.last_result[:min]
  end

end
