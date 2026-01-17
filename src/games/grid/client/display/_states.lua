local objects = require("games.grid.client.display.objects")
local util = require("util")
local stage_names = { "Humdrum", "ASDF" }

return {
  __START__ = {
    initialize = function(server_state) return server_state end,
    draw = function(self)
      for i, s in ipairs(stage_names) do
        print(self.cid)
        if i == self.state.players[self.cid].selection then s = ">> " .. s .. " <<" end
        love.graphics.print(s, 300, 300 + 20 * i)
      end
    end,
    update = function(self, update, param)
      if update == "addplayer" then
        local cid = param
        self.state.players[cid] = { selection = 1 }
      elseif update == "removeplayer" then
        local cid = param
        self.state.players[cid] = nil
        if cid == self.cid then self.playing = false end
      elseif update == "setselection" then
        local cid, selection = param:match("^(%S-),(%S+)")
        self.state.players[cid].selection = tonumber(selection)
      end
    end,

    love_update = function(self, dt) end,
  },
  __PLAY__ = {
    initialize = function(server_state)
      local state = { macrostate = server_state.macrostate, eaten_pits = {}, pits = {}, players = {}, walls = {}, num_players = 0 }
      W, H = love.graphics.getWidth(), love.graphics.getHeight()
      state.size = server_state.size
      state.dH = H / state.size
      state.dW = W / state.size
      for cid, player in pairs(server_state.players) do
        state.players[cid] = objects.Player:new(player.i, player.j, cid)
        state.num_players = state.num_players + 1
      end
      for i = 0, state.size - 1 do
        for j = 0, state.size - 1 do
          local l = i + state.size * j + 1
          if server_state.pits[l] then state.pits[l] = objects.Pit:new(i, j) end
          state.walls[l] = server_state.walls[l]
        end
      end
      return state
    end,
    draw = function(self)
      love.graphics.setColor(1, 1, 1)
      for _x = self.state.dW, W, self.state.dW do love.graphics.line(_x, 0, _x, H) end
      for _y = self.state.dH, H, self.state.dH do love.graphics.line(0, _y, W, _y) end
      do
        local _x, _y = self.state.dW / 2, self.state.dH / 2
        for _i = 0, self.state.size * self.state.size - 1 do
          if _i > 0 then
            if _i % self.state.size == 0 then
              _x = self.state.dW / 2
              _y = _y + self.state.dH
            else
              _x = _x + self.state.dW
            end
          end
          if self.state.walls[_i + 1] then
            love.graphics.setColor(.3, .4, .5)
            love.graphics
              .rectangle("fill", _x - .9 * self.state.dW / 2, _y - .9 * self.state.dH / 2, .9 * self.state.dW, .9 * self.state.dH)
          elseif self.state.pits[_i + 1] then
            self.state.pits[_i + 1]:draw(self.state.dH, self.state.size)
          end
        end
      end
      do
        love.graphics.setColor(0, .1, .3)
        love.graphics.rectangle("fill", 10, 10, 100, 20 * (1 + self.state.num_players))
        local ys = 20 -- pixel position for score
        love.graphics.setColor(1, 1, 1)
        for cid, player in pairs(self.state.players) do
          player:draw(self.state.dH, self.state.size)
          love.graphics.setColor(1, 1, 1)
          love.graphics.print(string.format("%s: %d   (%.2f, %.2f)", cid, player.score, player.i, player.j), 20, ys)
          ys = ys + 20
        end
      end
      for _, ep in ipairs(self.state.eaten_pits) do ep:draw(self.state.dW) end
    end,

    update = function(self, update, param)
      if update == "setplayer" then
        local cid, attr = param:match("^(%S-),(%S*)")
        for k, v in pairs(util.decode(attr)) do self.state.players[cid][k] = v end
      elseif update == "removepit" then
        local i, j = param:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
        local l = i + self.state.size * j + 1
        self.state.pits[l] = nil
        self.state.eaten_pits[#self.state.eaten_pits + 1] = objects.EatenPit:new(i, j)
      elseif update == "leave" then
        local cid = param
        self.state.players[cid] = nil
        if cid == self.cid then self.playing = false end
      elseif update == "score" then
        local cid = param
        self.state.players[cid].score = self.state.players[cid].score + 1
      else
        print(string.format("Unrecognized update '%s'", update))
      end
    end,

    love_update = function(self, dt)
      local ep = {}
      for _, pit in ipairs(self.state.eaten_pits) do if not pit:update(dt) then ep[#ep + 1] = pit end end
      self.state.eaten_pits = ep
      for _, pit in pairs(self.state.pits) do pit:update(dt) end
      for _, player in pairs(self.state.players) do player:update(dt) end
    end,
  },
  __END__ = {
    initialize = function(server_state) return server_state end,
    draw = function(self) end,
    update = function(self, update, param) end,
    love_update = function(self, dt) end,
  },
}

