local games = {}

games.current_game = nil

function games.load_game(g)
    games.current_game = require("games." .. g .. ".server")
    print(string.format("Playing %s", games.current_game.name))
end

games.load_game("grid")

return games

