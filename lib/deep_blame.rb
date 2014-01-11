require_relative "deep_blame/version"

module DeepBlame
  def self.line_history(path, start_line, end_line = nil, ref = 'HEAD')
    end_line ||= start_line
    command = "git blame -p -L #{start_line},#{end_line} #{path}"
    puts command
    system command
  end
end
