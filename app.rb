require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

def is_barber_exists? db, name
  db.execute('select * from barbers where name=?', [name]).size > 0
end

def seed_db db, barbers
  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute 'insert into barbers (name) values (?)', [barber]
    end
  end
end

before do
  db = get_db
  @barbers = db.execute 'select * from barbers'
end

configure do # Данный код будет работаь при перезапуске приложения, то есть, когда мы заного запускаем консоль
  db = get_db
  db.execute "create table if not exists 'users' ('id' integer primary key autoincrement, 'username' text, 'phone' intenger, 'datestamp' text, 'barber' text, 'color' text);"

  db.execute "create table if not exists 'barbers' ('id' integer primary key autoincrement, 'name' text);"

  seed_db db,["Jessie Pinkman", "Walter White", "Gus Fring", "Mike Ehrhament"]
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do


	erb :visit
end

post '/visit' do

	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

  # Validation for visit.erb
  validate = {
      username: "Введите имя",
      phone: "Введите телефон",
      datetime: "Введите время"
  }

  @error = validate.select {|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :visit
  end

  db = get_db
  db.execute "insert into users(name, phone, datestamp, barber, color) values (?, ?, ?, ?, ?)", [@username, @phone, @datetime, @barber, @color]

	erb "Спасибо, вы записаны."

end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @password = params[:pass]
  @email = params[:email]

  validation = {
      password: "Вы не ввели пароль",
      email: "Вы не ввели потовый адрес"
  }

  validation.each do |key, value|
    if params[key] == ''
      @error = value
    end

    if @password.size < 6
      @error = 'Ваш пароль слишком простой'
    elsif !@email.include?('@')
      @error = 'Вы ввели не почту'
    end
  end

  if @error != ''
		return erb :contacts
  end

  erb "Спасибо, мы получили ваши данные. Пароль: #{@password} и почта: #{@email}"
end

get '/showusers' do
  @db = get_db
  @result = @db.execute "select * from users order by id desc"

  erb :showusers
end