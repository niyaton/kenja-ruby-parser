module KenjaRubyParser
  class GitObject
    def initialize(type, name, contents)
      @type = type
      @name = name
      @contents = contents
    end

    def to_s
      lines = []
      case @type
      when :tree then
        lines << "[TS] #{@name}"
        @contents.each do |content|
          lines << content.to_s
        end
        lines << "[TE] #{@name}"
      when :blob then
        lines << "[BN] #{@name}"
        nlines = @contents.count("\n") + 1
        lines << "[BI] #{nlines}"
        lines << @contents
      end
      lines.join("\n")
    end
  end
end
