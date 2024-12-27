return function(consumable_dir, consumables)
  for k, ct in pairs(consumables) do
    if type(ct) == "string" then
      if type(k) == "number" then
        k = ct
      end
      ct = BalatroPlus.load(consumable_dir .. "/" .. ct) or ct
    end
    if type(ct) == "table" then
      ct.key = k
      if not ct.collection_rows then
        ct.collection_rows = { 5, 5 }
      end

      if type(ct.cards) == "table" then
        local dir = ct.cards.dir or ("consumables/" .. k)
        local prefix = ct.cards.key_prefix or ct.key

        local cards = {}
        for _, card_key in ipairs(ct.cards) do
          local c = BalatroPlus.load(dir .. "/" .. card_key)
          local key = prefix .. "_" .. card_key
          local _key = "c_bplus_" .. key

          c.set = ct.key
          c.key = key
          c.cost = c.cost or 4
          if type(c.unlocked) ~= "boolean" then
            c.unlocked = true
          end
          c.discovered = false
          SMODS.Consumable(c)

          cards[_key] = true
        end
        ct.cards = cards
      end

      SMODS.ConsumableType(ct)
    end
  end
end