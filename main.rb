require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do 
	def totalam(player)
			b = 0
			c = 0
			total = 0
			while b <= player.length-1
					if player[b][1] == 'A'
						c += 1
						total =  total + 11
					elsif player[b][1].to_i == 0 # J, Q, K
	     				 total += 10
					else
						total =  total + player[b][1]
					end
					b = b + 1
	 		end
	 		#Validate 'A'
	 		if total > 21
		 		d = 0
		 		while d < c
		 		  	total -= 10
		 		  	d += 1
		 		end
		   	end	
	 	total
	end
end

before do
	@stay_or_hit = true
end


get "/" do
	if session[:player_name]
		redirect "/game"
	else
		redirect "/new_player"
	end
end

get "/new_player" do 
	erb :new_player
end

post "/new_player" do 
	session[:player_name] = params[:player_name]
	redirect "/game"
end

get '/game' do
	suits = ['Hearts','Clubs','Diamonds','Spades']
 	values = ['A',1,2,3,4,5,6,7,8,9,10,'J','Q','K']
 	session[:deck] = suits.product(values).shuffle!
 	session[:dealer] = []
 	session[:player] = []
 	session[:dealer] << session[:deck].pop
 	session[:player] << session[:deck].pop
 	session[:dealer] << session[:deck].pop
 	session[:player] << session[:deck].pop
erb :game
end

post '/game/player/hit' do 
	session[:player] << session[:deck].pop
	if totalam(session[:player]) > 21
		@error = "Busted!!!"
		@stay_or_hit = false
	end
	erb :game
end

post '/game/player/stay' do 
	@success = 'You decided to stay'
	@stay_or_hit = false
	erb :game
end