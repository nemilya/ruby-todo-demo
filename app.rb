# Простое ToDo приложение
# на базе Ruby/Sinatra/DataMapper
#
#
require "rubygems"
require "sinatra"

require 'dm-core'
require 'dm-migrations'

# Таблица
# 
# todos
# - id [integer]
# - todo [string]
# - is_done [boolean]

class Todos
  include DataMapper::Resource
  property :id, Serial, :key => true
  property :todo, String
  property :is_done, Boolean, :default=>false
end

# для тестовых задач - настраиваем на БД Sqlite3
conn_string = "sqlite3://#{Dir.pwd}/todos.db"

# при выкладывании на CloudFoundry, и подключённом сервисе MySQL
# необходимо проинициализировать данные доступа к БД
# ENV['VCAP_SERVICES'] - переменная окружения проинициализированная CloudFoundry сервисом
configure :production do
  if ENV['VCAP_SERVICES']
    require "json"
    mysql_service = JSON.parse(ENV['VCAP_SERVICES'])['mysql-5.1'].first
    dbname   = mysql_service['credentials']['name']
    username = mysql_service['credentials']['username']
    password = mysql_service['credentials']['password']
    host     = mysql_service['credentials']['host']
    port     = mysql_service['credentials']['port']
    conn_string = "mysql://#{username}:#{password}@#{host}:#{port}/#{dbname}"
  end
end

# инициализируем DataMapper на адаптер Базы Данных
DataMapper.setup(:default, conn_string)

# обработка моделей
DataMapper.finalize

# автоматическая миграция, если
# изменились поля в модели
DataMapper.auto_upgrade!


# набор "функций-хелперов"
# добавляем хелпер "h" для автоматического
# преобразования html в безопасный для отображения html
helpers do
  def h(html_test)
    Rack::Utils.escape_html(html_test)
  end
end

# отображение страницы
get "/" do
  @todos = Todos.all(:is_done => false, :order => [:id.desc])
  @done_todos = Todos.all(:is_done => true, :order => [:id.desc])
  erb :index
end

# обработка на нажатие `[Кнопка Добавить]` - 
# добавление пункта, передаётся `'text'`
post "/add" do
  todo = Todos.new(:todo => params[:text])
  todo.save
  redirect "/"
end

# обработка на нажатие `[Кнопка Выполнены]` - 
# отметка о выполненнии, передаётся массив `'ids[]'`
# передаётся `'text'`
post "/done" do
  if params[:ids]
    params[:ids].each do |todo_id|
      Todos.get(todo_id).update(:is_done => true)
    end
  end
  redirect "/"
end

# обработка на нажатие `[Кнопка Архивировать]` - 
# удаление всех выполненных todo пунктов
post "/archive" do
  Todos.all(:is_done => true).destroy
  redirect "/"
end


__END__

@@layout

<!DOCTYPE html>
<html>
  <head>
    <title>Ruby ToTo Demo App</title>
    <meta charset="utf-8" />
  </head>
  <body>
    <h1>Простое ToDo приложение</h1>
    <%= yield %>
    <br />
    <small>
      github:
        <a href="https://github.com/nemilya/ruby-todo-demo">source code</a> |
        <a href="https://github.com/nemilya/ruby-todo-demo/blob/master/spec.ru.md">docs</a>
    </small>
  </body>
</html>

@@index

<h2>Актуальные</h2>

<form action="/add" method="post">
  <input type="text" name="text">
  <input type="submit" value="Добавить">
</form>
<br />

<% if @todos.size > 0 %>
  <form action="/done" method="post">
    <% @todos.each do |todo| %>
      <input type="checkbox" name="ids[]" value="<%= todo.id %>"> <%= h todo.todo %><br />
    <% end %>
    <br />
    <input type="submit" value="Выполнены">
  </form>
<% end %>

<% if @done_todos.size > 0 %>
  <h2>Выполненные</h2>

  <form action="/archive" method="post">
    <% @done_todos.each do |todo| %>
      <del><%= h todo.todo %></del><br />
    <% end %>
    <br />
    <input type="submit" value="Архивировать">
  </form>
<% end %>