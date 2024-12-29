local s = {
  loc_txt = {
    name = "Beast",
    text = {
      "Enhance up to {C:attention}#1#{} selected cards",
      "with random {C:attention}Enhancement{} and {C:attention}Seal{}",
      "destroy other {C:attention}unselected{} cards with",
      "same amount of {C:attention}selected{} cards",
    },
  },
  config = { extra = 3 },
  atlas = 7,
}

function s:loc_vars(_, card)
  return { vars = { card.ability.extra } }
end

function s:can_use(card)
  return #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra
      and #G.hand.cards - #G.hand.highlighted >= #G.hand.highlighted
end

function s:use(card)
  G.E_MANAGER:add_event(Event {
    func = function()
      local enhancement = bplus_random_enhancement("c_bplus_sigil_beast_enhancement")
      local seal = bplus_random_seal("c_bplus_sigil_beast_seal")
      local destroyables = {}
      for _, card in ipairs(G.hand.cards) do
        if not card.highlighted then
          destroyables[#destroyables + 1] = card
        end
      end

      for i = 1, #G.hand.highlighted do
        local card_to_destroy = pseudorandom_element(destroyables, pseudoseed("c_bplus_sigil_beast_destroy"))
        G.E_MANAGER:add_event(Event {
          trigger = "after",
          func = function()
            card_to_destroy:start_dissolve(nil, nil, 1.3)
            play_sound('slice1', 0.96 + math.random() * 0.05)
            return true
          end
        })
        local i = 1
        for index, card in ipairs(destroyables) do
          if card == card_to_destroy then
            i = index
          end
        end
        table.remove(destroyables, i)
      end

      for _, card in ipairs(G.hand.highlighted) do
        G.E_MANAGER:add_event(Event {
          trigger = "after",
          delay = 0.1,
          func = function()
            card:flip()
            play_sound("card1", percent)
            card:juice_up(0.3, 0.3)
            return true
          end
        })
      end

      for _, card in ipairs(G.hand.highlighted) do
        G.E_MANAGER:add_event(Event {
          trigger = "after",
          delay = 0.2,
          func = function()
            card:set_seal(seal, nil, true)
            card:set_ability(enhancement)
            return true
          end
        })
      end

      for i, card in ipairs(G.hand.highlighted) do
        local percent = 0.85 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
        G.E_MANAGER:add_event(Event {
          trigger = "after",
          delay = 0.5,
          func = function()
            card:flip()
            play_sound("tarot2", percent, 0.6)
            card:juice_up(0.3, 0.3)
            return true
          end
        })
      end

      return true
    end
  })
end

return s
