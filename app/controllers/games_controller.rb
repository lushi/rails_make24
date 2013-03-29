class GamesController < ApplicationController
	include GamesHelper

  def home
  end

  def create
  	new_game
  	redirect_to '/play'
  end

  def play
  	game = Game.find_by_session_id(session[:session_id])
		if game
			@score = game.score
			unless game.deck.blank?
					game.draw_hand
					@hand = game.hand.split(",")
			else
				render 'game_over'
			end
		else
			redirect_to '/'
		end
	end

	def evaluate
		game = Game.find_by_session_id(session[:session_id])
		player_answer = params[:player_answer]
		@hand = game.hand.split(",")
		if game.input_valid?(player_answer, @hand)
			if game.make24?(player_answer)
				@score = game.score += 1
				@solution = 0
				flash.now[:success] = "Great job! That definitely makes 24."
			else
				@score = game.score -= 1
				@solution = game.solution(@hand) || 0
				flash.now[:error] = @solution == 0 ? "There's no solution." : "That's not right. The correct solution is: #{@solution}."
			end
		else
			@score = game.score
			flash.now[:error] = "That's not a valid input. Try again."
		end
		game.save
		render 'play'
	end

	def solution
		game = Game.find_by_session_id(session[:session_id])
		@hand = game.hand.split(",").map(&:to_i)
		@solution = game.solution(@hand) || 0
		if @solution == 0
			@score = game.score += 1
			flash.now[:success] = "Good job. There's no solution."
		else
			@score = game.score -= 1
			flash.now[:error] = "The solution is: #{@solution}."
		end
		game.save
		render 'play'
	end

	def destroy
		Game.find_by_session_id(session[:session_id]).destroy
		redirect_to '/'
	end
end