require 'find_solution'
class Game < ActiveRecord::Base
  attr_accessible :deck, :score, :session_id, :hand, :player_answer

  validates :score, presence: true
  validates :session_id, presence: true, uniqueness: true

  def draw_hand
  	deck = self.deck.split(",")
		hand = deck.sample(4).each { |card| deck.delete_at(deck.index(card)) }
		self.update_attributes(hand: hand.join(","), deck: deck.join(","))
	end

	def input_valid?(player_answer, hand)
		match_regexp?(player_answer) && right_num?(player_answer, hand) && complete_paren?(player_answer)
	end

	def match_regexp?(player_answer)
		reg = /\A\({0,3}\s*\d{1,2}\s*(\*|\+|-|\/)\s*\({0,2}\s*\d{1,2}\s*\)?\s*(\*|\+|-|\/)\s*\(?\s*\d{1,2}\s*\){0,2}\s*(\*|\+|-|\/)\s*\d{1,2}\s*\){0,3}\z/
		(player_answer.match reg) ? true : false
	end

	def right_num?(player_answer, hand)
		player_answer_num = player_answer.gsub(/(\(|\)|\*|\+|-|\/)/, " ").split(" ").reject(&:empty?)
		player_answer_num.sort == hand.sort
	end

	def complete_paren?(player_answer)
		openp = player_answer.split(//).select {|c| c == '('}
		closep = player_answer.split(//).select {|c| c == ')'}
		openp.length == closep.length
	end

	def make24?(player_answer)
		eval(player_answer) == 24
	end

	def solution(hand)
		FindSolution.new(hand).print_solution
	end

	def solution_raw(hand)
		FindSolution.new(hand).solution
	end
end