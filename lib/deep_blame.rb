require 'pry'
require_relative "deep_blame/version"

module DeepBlame
  def self.line_history(path, start_line, end_line = nil, rev = 'HEAD')
    blames = Blame.find(rev, path, start_line, end_line)
    blames.each {|blame| display(blame) }
  end

  def self.display(blame)
    print "Blame shas: #{blame.short_sha}"
    while (blame = blame.parent) do
      print " -> #{blame.short_sha}"
    end
    puts "."
  end

  class Blame
    def self.find(rev, path, start_line, end_line = nil)
      end_line ||= start_line
      command = "git blame -b --incremental -l -L #{start_line},#{end_line} #{rev} #{path}"
      # puts "Running: #{command}"
      result = `#{command}`
      segments = result.scan(/[\s\S]+?filename.+/)
      segments.collect do |segment|
        new parse_segment(segment)
      end
    end

    def self.parse_segment(blame)
      first_line = blame.slice!(/.+/)
      hsh = [:sha, :line_number_original_file, :line_number_final_file,
       :line_number_group].inject({}) do |h, attr|
        h[attr] = first_line.slice!(/\w+/) ; h
      end
      hsh[:line_number_group] = nil if hsh[:line_number_group] == 0
      blame.strip.split("\n").inject(hsh) do |h, line|
        key = line.slice!(/\S+/)
        key = key.gsub("-","_").to_sym
        h[key] = line.strip.empty? ? true : line.strip
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

    def short_sha
      sha[0..6]
    end

    def previous_sha
      previous[/^\S+/]
    end

    def previous_file
      previous.sub(/^\S+\s+/,'')
    end

    def previous_line_number
      line_number_original_file
    end

    # rev, path, start_line, end_line = nil
    def parent
      self.class.find(previous_sha, previous_file, previous_line_number).first unless boundary
    end
  end
end
