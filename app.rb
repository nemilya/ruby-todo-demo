# 
# 
require "rubygems"
require "sinatra"


# отображение страницы
get "/" do
  erb :index
end

# обработка на нажатие `[Кнопка Добавить]` - 
# добавление пункта, передаётся `'text'`
post "/add" do
  redirect "/"
end

# обработка на нажатие `[Кнопка Выполнены]` - 
# отметка о выполненнии, передаётся массив `'ids[]'`
# передаётся `'text'`
post "/done" do
  redirect "/"
end

# обработка на нажатие `[Кнопка Архивировать]` - 
# удаление всех выполненных todo пунктов
post "/archive" do
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

    [текстовое поле] [Кнопка Добавить]

    // список todo пунктов, снизу вверх (по id)
    [checkbox] [текст todo1]
    [checkbox] [текст todo2]
    ...
    [Кнопка Выполнены]

    h2. Выполненные

    // список выполненных todo пунктов, 
    // с сортировкой снизу вверх (по id)
    // визуально перечёркнуты
    [текст done-todo1]
    [текст done-todo2]
    ...
    [Кнопка Архивировать]
</pre>