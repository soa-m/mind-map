require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
require 'active_support/all'
require 'json'
enable :sessions

get '/' do
    @card = Card.all.order("created_at desc")
    if @card.empty?
        @empty = true
    else
        @empty = false
    end
    erb :index
end

post '/related_word/:id' do
    id = params[:id]
    aaa = Card.find(id).tag
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
    Card.create(
        content: content,
        tag: tag,
        generated: true
    )
    end
    base = Card.find(id)
    base.base = true
    base.save
    session.clear
    redirect '/'
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
    Card.create(
        content: thema,
        tag: 1,
        generated: false
    )
    card = Card.last
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
    Card.create(
        content: thema,
        tag: tag,
        generated: false
    )
    card = Card.last
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
    session.clear
    id = params[:id]
    thema = params[:thema]
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
    session.clear
end