require 'game_mechanics'
require 'find_solution'

$games_db = {}

class Game
	STD_DECK = (1..10).to_a * 4 + [1, 1, 1] * 4
	def initialize(session_id)
		$games_db[session_id] = Make24App.new(STD_DECK.dup, 1)
	end
end

class Make24App < GameMechanics
	def solution
		FindSolution.new(*@hand).print_solution
	end
end
