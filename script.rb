require 'colorize'
# movements and colors
module Movements
  COLORS = {
    black: '    black    '.on_black,
    white: '   white   '.on_white,
    cyan: '   cyan     '.on_cyan,
    blue: '   blue     '.on_blue,
    yellow: '    yellow    '.on_yellow,
    green: '    green    '.on_green,
    magenta: '    magenta    '.on_magenta,
    red: '    red    '.on_red
  }.freeze

  # verify if the player's selection is valid
  def valid_selection_of_color(selection)
    if selection.is_a?(Symbol)
      if COLORS.keys.include?(selection)
        selection
      else
        puts 'Invalid color'
        false
      end
    end
  end

  def color_not_selected(code, color)
    if code.any?(color)
      puts 'Invalid color, please select a color that has not been selected'
      false
    else
      true
    end
  end

  def select_color(code)
    user_color = gets.chomp.to_sym until valid_selection_of_color(user_color) && color_not_selected(code, user_color)
    user_color.to_sym
  end

  def select_code
    code = Array.new(4)
    4.times do |i|
      puts "Select your choice #{i + 1} #{COLORS.values.join(' ')}"
      color = select_color(code)
      code[i] = color
    end
    code
  end

  def all_combinations
    COLORS.keys.permutation(4).to_a
  end

  def random_code
    all_combinations.sample
  end
end

# the codemaker player
class CodeMaker
  include Movements
  attr_accessor :code, :name

  def initialize(name = 'computer')
    @name = name
    @code = Array.new(4)
  end

  def round
    @code = select_code
  end

  def win?(codebreaker)
    puts 'codemaker wins!' unless codebreaker.win
  end
end

# the codebreaker player
class CodeBreaker
  include Movements
  attr_accessor :name, :hits, :similarities, :code, :win

  def initialize(name = 'computer')
    @name = name
    @hits = 0
    @similarities = 0
    @code = Array.new(4)
    @posibilities = all_combinations
    @rounds = 12
    @win = false
  end

  def machine_round(codemaker)
    while @rounds.positive?
      if @code.empty?
        @code = choose_code
        get_feedback(codemaker)
        @rounds if win?
        restart_feedback
      else
        machine_code(codemaker)
      end
    end
  end

  def machine_code(codemaker)
    get_feedback(codemaker)
    keep_similarities
    @code = @posibilities.sample
    @rounds = 0 if win?
    restart_feedback
  end

  def keep_similarities
    if @hits.positive?
      @posibilities.filter! do |array|
        array.zip(@code).count { |a, b| a == b } == @hits
      end
    elsif @similarities.positive?
      @posibilities.filter! do |array|
        array.count { |element| @code.include?(element) } == @similarities
      end
    end
  end

  def game(codemaker)
    if @name == 'computer'
      machine_round(codemaker)
    else
      round(codemaker)
    end
    codemaker.win?(self)
  end

  def get_feedback(codemaker)
    4.times do |i|
      if codemaker.code[i] == @code[i]
        @hits += 1
      elsif codemaker.code.any?(@code[i])
        @similarities += 1
      end
    end
    puts "#{@name} had #{@hits} hits and #{@similarities} similarities"
  end

  def round(codemaker)
    while @rounds.positive?
      if win?
        @rounds = 0
      else
        restart_feedback
        @code = choose_code
        get_feedback(codemaker)
        @rounds -= 1
      end
    end
  end

  def choose_code
    @code = if @name == 'computer'
              machine_code
            else
              select_code
            end
  end

  def win?
    if @hits == 4
      puts "congratulations #{@name}. You win!"
      @win = true
    end
  end

  def restart_feedback
    @hits = 0
    @similarities = 0
  end
end
puts 'what is your name?'
name = gets.chomp
puts 'are you the codemaker or the codebreaker?'
player = gets.chomp.downcase until %w[codebreaker codemaker].include?(player)
if player == 'codebreaker'
  codemaker = CodeMaker.new
  codebreaker = CodeBreaker.new(name)
else
  codebreaker = CodeBreaker.new
  codemaker = CodeMaker.new(name)
end
if codemaker.name == 'computer'
  codemaker.code = codemaker.random_code
else
  codemaker.round
end
codebreaker.game(codemaker)
