module GamesHelper
	def start_game
		deck = (1..10).to_a * 4 + [1, 1, 1] * 4
		if current_game
			restart_game(deck)
		else
			new_game(deck)
		end
	end

	def current_game
		Game.find_by_session_id(session[:session_id])
	end

	def new_game(deck)
		Game.create(session_id: session[:session_id], deck: deck.join(","), score: 0)
	end

	def restart_game(deck)
		current_game.update_attributes(deck: deck.join(","), score: 0)
	end
end
