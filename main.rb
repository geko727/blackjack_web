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

	def card_image(card)
		suit = card[0]
		value = card[1]
		if ['J', 'Q', 'K', 'A'].include?(value)
			value = case card[1]
				when 'J' then 'jack'
				when 'Q' then 'queen'
				when 'K' then 'king'
				when 'A' then 'ace'
			end
		end
		"<img src='/images/cards/#{suit}_#{value}.jpg' style = 'width:80px; height:110px;'>"
	end

	def winner(msg)
		session[:money] = session[:money].to_i + session[:bet].to_i
		@success = "#{msg}"
		@stay_or_hit = false
		@play_again = true
		@dealer_show_total = true
		
	end

	def loser(msg)
		session[:money] = session[:money] - session[:bet]
		@error = "#{msg}"
		@stay_or_hit = false
		@play_again = true
		@dealer_show_total = true
		if session[:money] == 0 then
			@play_again = false
			@nobet = true
		end
	end
end

before do
	@stay_or_hit = true
	@dealer_btn = false
	@play_again = false
	@dealer_show_total = false
	@nobet = false
end


get "/" do
	if session[:player_name]
		redirect "/game"
	else
		redirect "/start"
	end
end

get "/start" do
	erb :start
end

post "/new" do
	redirect "/new_player"
end


get "/new_player" do
	session[:money] = 500
	erb :new_player
end

post "/new_player" do 
	if params[:player_name].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end
	session[:player_name] = params[:player_name]
	redirect "/bet"
end

get '/bet' do 
	session[:bet] = nil
	erb :bet
end


post "/bet" do 
	if params[:bet_amount].empty?
		@error = "bet is required"
		halt erb(:bet)
	end
	session[:bet] = params[:bet_amount].to_i
	redirect "/game"
end

get '/game' do
	session[:turn] = session[:player_name]
	suits = ['hearts','clubs','diamonds','spades']
 	values = ['A',2,3,4,5,6,7,8,9,10,'J','Q','K']
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
	player_total = totalam(session[:player])
	#if player_total == 21
		#@success = "Congratulations!!!"
		#@stay_or_hit = false
	if totalam(session[:player]) > 21
		loser("Sorry #{session[:player_name]}, you busted.")
	end
	erb :game
end

post '/game/player/stay' do
	#winner ("#{session[:player_name]} decided to stay")
	redirect '/game/dealer'
end

get '/game/dealer' do
	session[:turn] = "dealer"
	dealer_total = totalam(session[:dealer])
	player_total = totalam(session[:player])
	if dealer_total == 21 && dealer_total > player_total
		loser("#{session[:player_name]} lost, dealer hit BlackJack")
	elsif dealer_total == 21 && player_total == 21
		winner("It's a tie")
	elsif dealer_total > 21
		winner("Congratulations #{session[:player_name]}!!! Dealer's cards exceed 21")
	elsif dealer_total >= 17
		redirect '/game/compare'
	else
		@dealer_btn = true
	end
	erb :game
end

post '/game/dealer/hit' do 
		session[:dealer] << session[:deck].pop
		redirect '/game/dealer'
end

get '/game/compare' do  
	dealer_total = totalam(session[:dealer])
	player_total = totalam(session[:player])
	if dealer_total > player_total 
		loser("Sorry #{session[:player_name]}, Dealer's cards are closer to 21 than yours.")
	elsif  player_total > dealer_total 
		winner("Congratulations #{session[:player_name]}!!! Your cards are closer to 21 than Dealer's cards.")
	elsif player_total == 21 && dealer_total < player_total
		winner("Congratulations #{session[:player_name]} You hit Blackjack")
	else
		winner("It's a tie")
	end
	erb :game
end

get '/game_over' do
	erb :game_over
end