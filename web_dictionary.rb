require "webrick"
require "yaml"


class DisplayDictionary < WEBrick::HTTPServlet::AbstractServlet

  TEMPLATE = %{
    <html>
    <head>
      <style>
        body {
          background-color: #F1F1F1;
        }
        a {
          color: #696969;
        }
        a:visited {
          color: #696969;
        }
        a:hover {
          color: #151515;
        }
        form {
          padding: 20px 0 0 0;
        }
        li {
          list-style-type: none;
          padding: 10px 10px;
          margin: 10px 0;
          background-color: #FFFFFF;
          max-width: 90%;
          border-radius: 3px;
          border-right: 1px solid #e4e4e4;
          border-bottom: 1px solid #e4e4e4;
        }
        p {
          color: #273237;
          font-family: sans-serif;
          font-size: 30px;
          font-weight: bold;
        }
      </style>
    </head>
      <body>
        <a href="/add"> To add a word, click here </a>
        <form method="POST" action="/search">
          <span>Search</span>
          <input name="to_search" type="search">
          <button type="submit"> Search it! </button>
        </form>

        <p>Dictionary</p>
        <p>
        <ul>
        <% dictionary.each do |hash| %>
          <li>
          <%= hash[:word] %> =
          <%= hash[:definition] %>
          </li>
          <% end %>
        </ul>
        </p>

      </body>
    </html>
    }

  def do_GET(request, response)

    if File.exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end

    # dictionary_lines = File.readlines("dictionary.txt")
    # dictionary_html = "<ul>" + dictionary_lines.map { |line| "<li>#{line}</li>" }.join + "</ul>"

    response.status = 200
    response.body = ERB.new(TEMPLATE).result(binding)
  end
end


class AddToDictionary < WEBrick::HTTPServlet::AbstractServlet
  TEMPLATE = %{
    <html>
    <head>
      <style>
      body {
        background-color: #F1F1F1;
      }
      li {
        list-style-type: none;
        padding: 0 0 20px 0;
      }
      form {
        padding: 10px 0 0 0;
      }
      .search {
        color: #273237;
        font-family: sans-serif;
        font-size: 14px;
      }
      p {
        color: #273237;
        font-family: sans-serif;
        font-size: 30px;
        font-weight: bold;
      }
      </style>
    </head>
      <body>
        <p> Let's Add a Word! </p>
        <form method="POST" action="/save">
          <span class="search">Word</span>
          <input name="word"/>
          <span class="search">Definition</span>
          <input name="definition"/>
          <button type="submit"> Add it! </button>
        </form>
      </body>
    </html>
    }

  # This gets called when the user clicks the link from the "/" page
  def do_GET(request, response)

    response.status = 200
    response.body = ERB.new(TEMPLATE).result(binding)
  end
end


class SaveToDatabase < WEBrick::HTTPServlet::AbstractServlet
  # This is called when the user submits the form from the "/add" page
  # They get here because the "/add" page gave "/save" as the action.

  TEMPLATE = %{
    <html>
    <head>
      <style>
      body {
        background-color: #F1F1F1;
      }
      p {
        color: #273237;
        font-family: sans-serif;
        font-size: 30px;
        font-weight: bold;
      }
      </style>
    </head>
      <body>
        <p>Saved!</p>
      </body>
    </html>
  }

  def do_POST(request, response)


    if File.exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end
    word = request.query["word"]
    definition = request.query["definition"]
    new_word = {word: word, definition: definition}
    dictionary << new_word
    File.write("data.yml", dictionary.to_yaml)


    response.status = 302
    response.header["Location"] = "/"
    response.body = ERB.new(TEMPLATE).result(binding)
  end
end

class SearchDatabase < WEBrick::HTTPServlet::AbstractServlet

  TEMPLATE = %{
    <html>
      <head>
        <style>
        body {
          background-color: #F1F1F1;
        }
        a {
          color: #696969;
        }
        a:visited {
          color: #696969;
        }
        a:hover {
          color: #151515;
        }
        form {
          padding: 20px 0 0 0;
        }
        li {
          list-style-type: none;
          padding: 10px 10px;
          margin: 10px 0;
          background-color: #FFFFFF;
          max-width: 90%;
          border-radius: 3px;
          border-right: 1px solid #e4e4e4;
          border-bottom: 1px solid #e4e4e4;
        }
        p {
          color: #273237;
          font-family: sans-serif;
          font-size: 30px;
          font-weight: bold;
        }
        </style>
      </head>
      <body>
      <a href="/"> Back to full dictionary </a>
      <p> Search Results </p>
        <ul>
        <% search_results.each do |hash| %>
          <li>
            <%= hash[:word]%> =
            <%= hash[:definition]%>
          </li>
        <% end %>
        </ul>
      </p>
      </body>
    </html>
  }

  def do_POST(request, response)

    if File.exist?("data.yml")
      dictionary = YAML::load(File.read("data.yml"))
    else
      dictionary = []
    end

    search_results = dictionary.select { |hash| hash[:word] == request.query["to_search"] }
    # search_html = "<ul>" + search_results.map { |hash| "<li>#{hash[:word]} : #{hash[:definition]}</li>" }.join + "</ul>"

    response.status = 200
    response.body = ERB.new(TEMPLATE).result(binding)
  end
end


server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/", DisplayDictionary
server.mount "/add", AddToDictionary
server.mount "/save", SaveToDatabase
server.mount "/search", SearchDatabase

trap "INT" do server.shutdown end
server.start
