local j = {
  loc_txt = {
    name = "Memory Card",
    text = {
      "Save remaining {C:blue}hand",
      "for next round",
      "{C:inactive}({C:blue}#1#{C:inactive}/{C:blue}#2#{C:inactive} Saved)",
    },
  },
  config = { extra = 0, max_saved_hand = 6 },
  rarity = 1,
  cost = 4,
  atlas = 13,

  blueprint_compat = false,
}

function j:loc_vars(_, card)
  return { vars = { card.ability.extra, self.config.max_saved_hand } }
end

function j:calculate(card, ctx)
  if ctx.end_of_round and not ctx.individual and not ctx.repetition
      and G.GAME.current_round.hands_left > 0 and card.ability.extra < self.config.max_saved_hand then
    local saved = G.GAME.current_round.hands_left
    if card.ability.extra + saved >= self.config.max_saved_hand then
      saved = self.config.max_saved_hand - card.ability.extra
    end

    card.ability.extra = card.ability.extra + saved
    ease_hands_played(-saved, true)
    card_eval_status_text(card, 'extra', nil, nil, nil, {
      message = saved .. " Saved!",
      colour = G.C.BLUE,
    })
  elseif ctx.setting_blind and not card.getting_sliced and card.ability.extra > 0 then
    local hands = card.ability.extra
    card.ability.extra = 0

    G.E_MANAGER:add_event(Event {
      func = function()
        ease_hands_played(hands)
        card_eval_status_text(card, 'extra', nil, nil, nil, {
          message = localize {
            type = 'variable',
            key = 'a_hands',
            vars = { hands },
          },
          colour = G.C.BLUE,
        })
        return true
      end
    })
  end
end

return j