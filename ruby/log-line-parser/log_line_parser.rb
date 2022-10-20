# this is a comment
class LogLineParser
  def initialize(line)
    @line = line
  end

  def split_line
    @line.split(":")
  end

  def message
    split_line[1].strip
  end

  def log_level
    level = split_line[0].downcase
    level.slice(1..-2)
  end

  def reformat
    "#{message} (#{log_level})"
  end
end
