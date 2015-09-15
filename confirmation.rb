require 'term/ansicolor'

# Get confirmation in a Yes/No stylee
class Confirm
  extend Term::ANSIColor

  def self.ask(prompt, normal = white, highlight = yellow)
    print normal + prompt + '? (' + highlight + 'Y' + normal + '/' + highlight +
      'N' + normal + ') '

    return $stdin.gets.downcase[0] == 'y'
  end
end

