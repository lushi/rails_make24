class GamesController < ApplicationController
	include GamesHelper

  def home
  end

  def create
  	start_game
  	redirect_to '/play'
  end

  def play
  	@game = current_game
  	direct_to '/' if @game.nil?
  	@game.play
		render 'game_over' if @game.over?
	end

	def evaluate
		@game = current_game
		player_answer = params[:player_answer]
		begin
			@game.make_move_answer(player_answer)
			if @game.success?
				@message = "Great job! That definitely makes 24."
			else
				@message = @game.solution ? "Nope. The solution is: #{@game.solution}." : "There is no solution."
			end
			@game.save
			render 'message'
		rescue GameError
			flash.now[:error] = "That's not a valid input. Try again."
			render 'play'
		end
	end

	def solution
		@game = current_game
		@game.make_move_solution
		if @game.success?
			@message = "Good job. There is no solution."
		else
			@message = "The solution is: #{@game.solution}."
		end
		@game.save
		render 'message'
	end

	def destroy
		current_game.destroy
		redirect_to '/'
	end
end