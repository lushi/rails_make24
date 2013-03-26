class GamesController < ApplicationController
  def home
  end

  def play
  	@hand = [1,2,3,4]
  end
end
