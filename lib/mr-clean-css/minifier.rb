require 'open3'

class MrCleanCSS::Minifier

  # See README.md for a description of each option, and see
  # https://github.com/GoalSmashers/clean-css#how-to-use-clean-css-programmatically
  # for the JS translation.
  #
  def initialize(options)
    js_opts = {
      'processImport' => true
    }

    cmd = ['cleancss']

    if options.has_key?(:keep_special_comments)
      js_opts['keepSpecialComments'] = {
        'all' => '*',
        'first' => 1,
        'none' => 0,
        '*' => '*',
        '1' => 1,
        '0' => 0
      }[options[:keep_special_comments].to_s]
    end

    if options.has_key?(:keep_breaks)
      js_opts['keepBreaks'] = options[:keep_breaks] ? true : false
    end

    if options.has_key?(:root)
      js_opts['root'] = options[:root].to_s
    end

    if options.has_key?(:relative_to)
      js_opts['relativeTo'] = options[:relative_to].to_s
    end

    if options.has_key?(:process_import)
      js_opts['processImport'] = options[:process_import] ? true : false
    end

    if options.has_key?(:no_rebase)
      js_opts['noRebase'] = options[:no_rebase] ? true : false
    elsif !options[:rebase_urls].nil?
      js_opts['noRebase'] = options[:rebase_urls] ? false : true
    end

    if options.has_key?(:no_advanced)
      js_opts['noAdvanced'] = options[:no_advanced] ? true : false
    elsif !options[:advanced].nil?
      js_opts['noAdvanced'] = options[:advanced] ? false : true
    end

    if options.has_key?(:rounding_precision)
      js_opts['roundingPrecision'] = options[:rounding_precision].to_i
    end

    if options.has_key?(:compatibility)
      js_opts['compatibility'] = options[:compatibility].to_s
      unless ['ie7', 'ie8'].include?(js_opts['compatibility'])
        raise(
          'Ruby-Clean-CSS: unknown compatibility setting: '+
          js_opts['compatibility']
        )
      end
    end

    if options.has_key?(:benchmark)
      js_opts['benchmark'] = options[:benchmark] ? true : false
    end

    if options.has_key?(:debug)
      js_opts['debug'] = options[:debug] ? true : false
    end

    # Set up command
    if js_opts['debug']
      cmd << "--debug"
    end

    # Set up command
    if !js_opts['processImport']
      cmd << "--skip-import"
    end

    # Set up command
    if js_opts['keepBreaks']
      cmd << "--keep-line-breaks"
    end

    @js_opts = js_opts
    @cmd = cmd.join(" ")
  end

  def minify(contents)
    out = nil
    return_value = nil
    errors = []
    err = nil

    Open3.popen3(@cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.write(contents)
      stdin.close
      out = stdout.read
      err = stderr.read
      return_value = wait_thr.value
    end

    unless return_value.success?
      errors << err
    end

    return {
      min:  out,
      errors: errors,
      warnings: {},
    }
  end
end
