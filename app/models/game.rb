class Game < ActiveRecord::Base
  attr_accessible :deck, :score, :session_id, :hand
  #TODO: Use Marhsal to save game state as one string
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
		FindSolution.new(cards).print_solution
	end

	def over?
		deck.blank?
	end
end

class GameError < RuntimeError
end

class FindSolution
	attr_reader :numbers
	def initialize(num_array)
		@numbers = num_array.map(&:to_f).sort.reverse
	end

	def operators
		%w(+ - * /)
	end

	def apply_ops_seq(number, op)
		number[0].send(op[0], number[1]).
			send(op[1], number[2]).
			send(op[2], number[3])
	end

	def apply_ops_nonseq(number, op)
		number[0].send(op[0], number[1]).
			send(op[1], number[2].send(op[2], number[3]))
	end

	def good_permutation(nums, ops)
		(0 if 24 == apply_ops_seq(nums, ops)) || (1 if 24 == apply_ops_nonseq(nums,ops))
	rescue ZeroDivisionError
		nil
	end

	def solution
		numbers.permutation 4 do |nums|
			operators.repeated_permutation 3 do |ops|
				if good_permutation(nums, ops)
					return [nums.map(&:to_i), ops, good_permutation(nums, ops)]
				end
			end
		end
		nil
	end

	def print_solution
		s = solution
		add_paren(s) if s
	end

	def add_paren(s)
		if s[2] == 0
			"((#{s[0][0]} #{s[1][0]} #{s[0][1]}) #{s[1][1]} #{s[0][2]}) #{s[1][2]} #{s[0][3]}"
		else
			"(#{s[0][0]} #{s[1][0]} #{s[0][1]}) #{s[1][1]} (#{s[0][2]} #{s[1][2]} #{s[0][3]})"
		end
	end
end