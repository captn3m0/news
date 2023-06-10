# Monkey patch to fix the inline_script bug
module HtmlPress
  def self.js_compressor (text, options = nil)
    options ||= {}
    # This line is commented
    # options[:inline_script] = true
    MultiJs.compile(text, options).gsub(/;$/,'')
  end
end
