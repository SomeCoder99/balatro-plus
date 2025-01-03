local s = {
  loc_txt = {
    name = "Klone",
    text = {
      "Create copy of up",
      "to {C:attention}#1#{} selected",
      "cards",
    },
  },
  config = { extra = 3 },
  atlas = 13,
}

function s:loc_vars(_, card)
  return { vars = { card.ability.extra } }
end

function s:can_use(card)
  return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra
end

function s:use(card)
  G.E_MANAGER:add_event(Event({
    func = function()
      local _first_dissolve = nil
      local new_cards = {}
      for i, card_to_copy in ipairs(G.hand.highlighted) do
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local _card = copy_card(card_to_copy, nil, nil, G.playing_card)
        _card:add_to_deck()
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        table.insert(G.playing_cards, _card)
        G.hand:emplace(_card)
        _card:start_materialize(nil, _first_dissolve)
        _first_dissolve = true
        new_cards[#new_cards + 1] = _card
      end
      playing_card_joker_effects(new_cards)
      return true
    end
  }))
end

return s