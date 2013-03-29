module GamesHelper
	def new_game
		deck = (1..10).to_a * 4 + [1, 1, 1] * 4
		Game.create(session_id: session[:session_id], deck: deck.join(","), score: 0) ||
		Game.find_by_session_id(session[:session_id]).update_attributes(deck: deck.join(","), score: 0)
	end
end
