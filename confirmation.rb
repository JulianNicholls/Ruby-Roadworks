require 'term/ansicolor'

# Get confirmation in a Yes/No stylee
class Confirm
  extend Term::ANSIColor

  def self.ask(prompt, normal = white, high = yellow)
    print normal + prompt + '? (' + highlight('Y', high, normal) + '/' +
      highlight('N', high, normal) + ') '

    $stdin.gets.downcase[0] == 'y'
  end

  def self.highlight(text, highlight = yellow, normal = white)
    highlight + text + normal
  end
end
