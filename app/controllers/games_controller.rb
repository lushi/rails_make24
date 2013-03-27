class GamesController < ApplicationController
  def home
  	Game.new(session[:session_id])
  	puts "session: #{session}"
  end

  def play
  	puts "session: #{session}"
		if $games_db[session[:session_id]].nil?
			redirect_to '/home'
		else
			@score = $games_db[session[:session_id]].score[0]
			unless $games_db[session[:session_id]].terminal?
				@hand = $games_db[session[:session_id]].draw_hand
			else
				$games_db.delete(session[:session_id])
				render 'game_over'
			end
		end
	end

	def evaluate
		puts "session: #{session}"
		@hand = $games_db[session[:session_id]].hand
		$games_db[session[:session_id]].player_answer = params[:player_answer]
		if $games_db[session[:session_id]].input_valid?
			if $games_db[session[:session_id]].make24?
				$games_db[session[:session_id]].score[0] += 1
				@score = $games_db[session[:session_id]].score[0]
				@solution = 0
				flash.now[:success] = "Great job! That definitely makes 24."
			else
				$games_db[session[:session_id]].score[0] -= 1
				@score = $games_db[session[:session_id]].score[0]
				@solution = $games_db[session[:session_id]].solution || 0
				flash.now[:error] = @solution == 0 ? "No solution." : "That's not right. The correct solution is: #{@solution}."
			end
		else
			@score = $games_db[session[:session_id]].score[0]
			flash.now[:error] = "That's not a valid input. Try again."
		end
		render 'play'
	end

	def solution
		puts "session: #{session}"
		@hand = $games_db[session[:session_id]].hand
		@solution = $games_db[session[:session_id]].solution || 0
		if @solution == 0
			$games_db[session[:session_id]].score[0] += 1
			@score = $games_db[session[:session_id]].score[0]
			flash.now[:success] = "Good job. There's no solution."
		else
			$games_db[session[:session_id]].score[0] -= 1
			@score = $games_db[session[:session_id]].score[0]
			flash.now[:error] = "The solution is: #{@solution}."
		end
		render 'play'
	end
end