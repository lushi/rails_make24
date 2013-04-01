class Game < ActiveRecord::Base
  attr_accessible :deck, :score, :session_id, :hand

  validates :score, presence: true
  validates :session_id, presence: true, uniqueness: true

  def play
  	draw_hand unless over?
  end

  def draw_hand
  	d = deck.split(",")
		hand = d.sample(4).each { |card| d.delete_at(d.index(card)) }
		update_attributes(hand: hand.join(","), deck: d.join(","))
	end

  def cards
		hand.split(",")
  end

	def input_valid?(player_answer)
		match_regexp?(player_answer) && right_num?(player_answer) && complete_paren?(player_answer)
	end

	def match_regexp?(player_answer)
		reg = /\A\({0,3}\s*\d{1,2}\s*(\*|\+|-|\/)\s*\({0,2}\s*\d{1,2}\s*\)?\s*(\*|\+|-|\/)\s*\(?\s*\d{1,2}\s*\){0,2}\s*(\*|\+|-|\/)\s*\d{1,2}\s*\){0,3}\z/
		(player_answer.match reg) ? true : false
	end

	def right_num?(player_answer)
		player_answer_num = player_answer.gsub(/(\(|\)|\*|\+|-|\/)/, " ").split(" ").reject(&:empty?)
		player_answer_num.sort == cards.sort
	end

	def complete_paren?(player_answer)
		openp = player_answer.split(//).select {|c| c == '('}
		closep = player_answer.split(//).select {|c| c == ')'}
		openp.length == closep.length
	end

	def make24?(player_answer)
		eval(player_answer) == 24 #TODO: don't use eval, parse string
	end

	def success?
		@success
	end

	def make_move_answer(answer)
		raise GameError unless input_valid?(answer)
		if make24?(answer)
			self.score += 1
			@success = true
		else
			self.score -= 1
			@success = false
		end
	end

	def make_move_solution
		unless solution
			self.score += 1
			@success = true
		else
			self.score -= 1
			@success = false
		end
	end

	def solution
		FindSolution.new(cards).solution
	end

	def over?
		deck.blank?
	end
end

class GameError < RuntimeError
end

class FindSolution
	attr_reader :numbers

	EXPRESSIONS = [
		'((%d %s %d) %s %d) %s %d',
		'(%d %s (%d %s %d)) %s %d',
		'(%d %s %d) %s (%d %s %d)',
		'%d %s ((%d %s %d) %s %d)',
		'%d %s (%d %s (%d %s %d))'
	]

	OPERATORS = %w(+ - * /)

	def initialize(num_array)
		@numbers = num_array
	end

	def good_permutation?(test)
		eval(test) == 24
	rescue ZeroDivisionError
		nil
	end

	def solution
		numbers.permutation do |a,b,c,d|
			OPERATORS.repeated_permutation(3) do |ops1,ops2,ops3|
				EXPRESSIONS.each do |exp|
					test = exp.gsub('%d', 'Rational(%d,1)') % [a, ops1, b, ops2, c, ops3, d]
					return exp % [a, ops1, b, ops2, c, ops3, d] if good_permutation?(test)
				end
			end
		end
		nil
	end
end