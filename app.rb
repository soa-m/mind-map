require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
require 'active_support/all'
require 'json'
enable :sessions

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
    def current_list
        List.find_by(id: session[:list])
    end
end

get '/' do
    if session[:user].nil?
        @current = 1
    else
        @current = 0
        @name = session[:name]
    end
    erb :home
end

get '/dash' do
    if session[:user].nil?
        @current = 1
    else
        @current = 0
        @name = session[:name]
        @list = current_user.lists
    end

    erb :dash
end

get '/check/:id' do
    id = params[:id]
    session[:list] = id
    
    puts "idは" + id
    redirect '/app'
end

get '/app' do
    if session[:user].nil?
        @current = 1
    else
        @current = 0
        @name = session[:name]
    end
    if session[:list].present?
    @card = current_list.cards.order("created_at desc")
    @newest = current_list.cards.all.size
    else
    @newest = 0
    end
    puts @card
    if @card.nil?
        @empty = "true"
    else
        @empty = "false"
    end
    erb :index
end

post '/related_word/:id' do
    list = session[:list]
    puts "listは" + list
    id = params[:id]
    aaa = current_list.cards.find(id).tag
    tag = aaa.to_i
    tag = tag + 1
    thema=params[:thema]
    @name = thema
    related_word = `python wordnet_jp.py #{thema}`
    related_word.delete!("[")
    related_word.delete!("]")
    related_word.delete!("'")
    related_word.delete!("\n")
    if related_word.empty?
        @new = ['該当なし']
    end
    if related_word.present?
    @new=related_word.split(",")
#    @new.insert(0, @name)
    end
    @new=@new.shuffle
    @new=@new.first(5)
    @new.each do |content|
    current_list.cards.create(
        content: content,
        tag: tag,
        parent: id,
        generated: true
    )
    end
    base = Card.find(id)
    base.base = true
    base.save
    redirect '/app'
end

get '/clear' do
    session.clear
end

post '/card2/:id' do
    id = params[:id]
    session[:current] = Card.find(id)
    current = Card.find(id)
    data = {content: current.content, base: current.base, id: current.id}
    content_type :json
    data.to_json
end

post '/save2' do
    thema = params[:thema]
    current_list.cards.create(
        content: thema,
        tag: 1,
        generated: false
    )
    card = current_list.cards.last
    data = {content: card.content, id: card.id, tag: card.tag}
    content_type :json
    data.to_json
end

post '/save3' do
    thema = params[:thema]
    id=params[:id]
    base=Card.find(id)
    base_tag = base.tag.to_i
    tag = base_tag + 1
    current_list.cards.create(
        content: thema,
        tag: tag,
        parent: id,
        generated: false
    )
    card = current_list.cards.last
    data = {content: card.content, id: card.id, tag: card.tag}
    content_type :json
    data.to_json
end

post '/position/:id' do
    id = params[:id]
    x = params[:x]
    y = params[:y]
    card = Card.find(id)
    card.x = x
    card.y = y
    card.save
end

post '/edit2/:id' do
    id = params[:id]
    thema = params[:thema]
    puts(thema)
    puts(id)
    str = Card.find(id)
    str.content = thema
    str.generated = false
    str.save
    card = Card.find(id)
    data = {content: card.content, id: card.id, tag: card.tag}
    content_type :json
    data.to_json
end

post '/delete2/:id' do
    id = params[:id]
    str = Card.find(id)
    str.destroy
end

post '/list' do
    current_user.lists.create(
        name: params[:name],
        detail: params[:detail]
        )
    redirect '/dash'
end

get '/signin' do
    erb :sign_in
end

get '/signup' do
    erb :sign_up
end

post '/signin' do
    user = User.find_by(mail: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
        session[:name] = user.mail
    end
    redirect '/dash'
end

post '/signup' do
    name = params[:name]
    check = User.where( mail: name)
    if check.empty?
    user = User.create(
        mail: params[:name], 
        password: params[:password], 
        password_confirmation: params[:password_confirmation]
    )
    if user.persisted?
        session[:user] = user.id
        session[:name] = user.mail
    end
    redirect '/dash'
    else
    return "そのユーザーネームはすでに使われています。ページを戻してから他のネームでお試しください。"
    end
    erb :sign_up
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

get '/destroy' do
    if session[:user].present?
    id = session[:user]
    user = User.find(id)
    user.destroy
    session[:user] = nil
    end
    redirect '/'
end

get '/dash/destroy/:id' do
    id = params[:id]
    list = current_user.lists.find(id)
    list.destroy
    session[:list] = nil
    redirect '/dash'
end

post '/dash/edit/:id' do
    id = params[:id]
    list = current_user.lists.find(id)
    list.name = params[:name]
    list.detail = params[:detail]
    list.save
    redirect '/dash'
end