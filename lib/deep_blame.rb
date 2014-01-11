require 'pry'
require_relative "deep_blame/version"

module DeepBlame
  def self.line_history(path, start_line, end_line = nil, ref = 'HEAD')
    end_line ||= start_line
    command = "git blame -b --incremental -l -L #{start_line},#{end_line} #{path}"
    puts command
    result = `#{command}`
    bims = BlameIncrementalMessage.divide(result)
    puts "Relevant hashes: #{bims.collect(&:sha).join(", ")}."
  end

  class BlameIncrementalMessage
    def self.divide(incremental_blame_output)
      segments = incremental_blame_output.scan(/[\s\S]+?filename.+/)
      segments.collect do |segment|
        new parse_segment(segment)
      end
    end

    def self.parse_segment(blame)
      first_line = blame.slice!(/.+/)
      hsh = {}
      hsh[:sha] = first_line.slice!(/\w+/)
      hsh[:line_number_original_file] = first_line.slice!(/\w+/).to_i
      hsh[:line_number_final_file]    = first_line.slice!(/\w+/).to_i
      hsh[:line_number_group]         = first_line.slice!(/\w+/).to_i
      hsh[:line_number_group] = nil if hsh[:line_number_group] == 0
      blame.strip.split("\n").inject(hsh) do |h, line|
        key = line.slice!(/\S+/)
        key.gsub!("-","_")
        key = key.to_sym
        h[key] = line.strip
        h[key] = true if h[key].empty?
        h
      end
    end

    attr_reader :data
    def initialize(data)
      @data = data
    end

    [:sha, :line_number_original_file, :line_number_final_file, :line_number_group,
     :author, :author_mail, :author_time, :author_tz, :committer, :committer_mail,
     :committer_time, :committer_tz, :summary, :boundary, :filename,
     :previous].each do |attr|
       define_method attr do
         data[attr]
       end
     end
  end
end
