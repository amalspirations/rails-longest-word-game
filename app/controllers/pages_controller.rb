# require 'open-uri'
# require 'json'
# require 'time'

class PagesController < ApplicationController

# ----- PAGES -----

  def game
    @grid = generate_grid(10)
    @start = DateTime.now
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid].chars
    @start_time = Time.parse(params[:time])
    @end_time = Time.now
    @result = run_game(@attempt, @grid, @start_time, @end_time)

    session[:number] ||= 0
    session[:number] += 1
    @times = session[:number]

    session[:scores] ||= []
    session[:scores] << @result[:score]
    @scores = session[:scores].reduce(:+) / session[:scores].length

    # render "pages/score"
  end

# ----- GAME CODE -----

  # Generate random grid of letters
  def generate_grid(grid_size)
    grid = []
    (0...grid_size).each { grid << ('A'..'Z').to_a.sample }
    return grid
  end

  def attempt_test?(attempt, grid)
    test = true
    attempt.each_char { |char| test = test && (grid.include? char.upcase) }
    return test
  end

  def repetition?(attempt, grid)
    attempt.split("").all? { |char| attempt.count(char) <= grid.count(char.upcase) }
  end

  def translate(attempt)
    key = "63ed7cd9-09e4-42f4-9294-25b61bb84c0a"
    website = "https://api-platform.systran.net/translation/text/translate"
    response = open("#{website}?source=en&target=fr&key=#{key}&input=#{attempt}")
    json = JSON.parse(response.read.to_s)
    translation = attempt != json["outputs"][0]["output"] ? json["outputs"][0]["output"] : "-"
    return translation
  end

  def english?(attempt)
    words = File.read('/usr/share/dict/words').upcase.split("\n")
    return words.include? attempt.upcase
  end

  def message(attempt, grid)
    if !attempt_test?(attempt, grid)
      return "Fail! You used characters not in the grid..."
    elsif !english?(attempt)
      return "Your attempt is not an English word!"
    elsif !repetition?(attempt, grid)
      return "Fail! You cannot repeat a character from the grid!"
    else
      return "Well done!"
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    result = {}
    result[:time] = (end_time - start_time).to_i
    result[:translation] = translate(attempt)
    result[:message] = message(attempt, grid)
    result[:score] = (result[:message] == "Well done!" ? (attempt.length * 1000 / result[:time]) : 0)
    return result
  end

end
