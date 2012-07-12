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
conn_string="sqlite3://#{Dir.pwd}/todos.db"

# инициализируем DataMapper на адаптер Базы Данных
DataMapper.setup(:default, conn_string)

# обработка моделей
DataMapper.finalize

# автоматическая миграция, если
# изменились поля в модели
DataMapper.auto_upgrade!


# отображение страницы
get "/" do
  @todos = Todos.all(:is_done => false, :order => [:id.desc])
  @done_todos = Todos.all(:is_done => true, :order => [:id.desc])
  erb :index
end

# обработка на нажатие `[Кнопка Добавить]` - 
# добавление пункта, передаётся `'text'`
post "/add" do
  p "add route"
  p params[:text]
  todo = Todos.new(:todo => params[:text])
  todo.save
  redirect "/"
end

# обработка на нажатие `[Кнопка Выполнены]` - 
# отметка о выполненнии, передаётся массив `'ids[]'`
# передаётся `'text'`
post "/done" do
  p "done route"
  p params[:ids]
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
  p "archive route"
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
    <%= yield %>
  </body>
</html>

@@index

<pre>
    h1. Простое ToDo приложение

    h2. Актуальные

    <form action="/add" method="post">
      <input type="text" name="text">
      <input type="submit" value="Добавить">
    </form>

<% if @todos.size > 0 %>
    <form action="/done" method="post">
    // список todo пунктов, снизу вверх (по id)
      <% @todos.each do |todo| %>
      <input type="checkbox" name="ids[]" value="<%= todo.id %>"> <%= todo.todo %>
      <% end %>
      <input type="submit" value="Выполнены">
    </form>
<% end %>

<% if @done_todos.size > 0 %>
    h2. Выполненные

    <form action="/archive" method="post">
    // список выполненных todo пунктов, 
    // с сортировкой снизу вверх (по id)
    // визуально перечёркнуты
      <% @done_todos.each do |todo| %>
        <del><%= todo.todo %></del>
      <% end %>
      <input type="submit" value="Архивировать">
    </form>
<% end %>
</pre>