# encoding: UTF-8
require "erb"

Templates = Pathname.new(File.dirname(__FILE__)) + 'templates'

def strip_comments(text)
    text.gsub(/^#.*$/, '')
end

def spaces(indent)
    ' ' * indent
end

def insert_string(string, indent = 0)
    result = string.strip
    spaces(indent) + result + "\n"
end

def insert(name, data = nil, indent = 0)
    result = strip_comments(ERB.new(File.read(Templates + (name + '.sh.erb'))).result(binding)).strip
    result.gsub!(/\n/, "\n" + spaces(indent)) if indent > 0
    result
end

def check(*tools, indent)
    result = insert_string('CHECK_NOTFOUND=""') + "\n"
    tools.each do |tool|
        name = tool.to_s
        case name
        when 'curl'
            command = 'curl --version'
        when 'gpg'
            command = 'gpg --version'
        when 'tar'
            command = 'tar --version'
        else
            raise 'Don\'t know how to check for ' + name
        end
        result += insert_string(%{CHECK_TOOL="#{name}"}, indent)
        result += insert_string(%{CHECK_COMMAND="#{command}"}, indent)
        result += spaces(indent) + insert('check', nil, indent) + "\n\n"
    end
    result += spaces(indent) + insert('notfound', nil, indent)
    result
end
