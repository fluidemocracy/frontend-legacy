local suggestion = param.get("suggestion", "table")

local plus2  = (suggestion.plus2_unfulfilled_count or 0)
    + (suggestion.plus2_fulfilled_count or 0)
local plus1  = (suggestion.plus1_unfulfilled_count  or 0)
local minus1 = (suggestion.minus1_unfulfilled_count  or 0)
    + (suggestion.minus1_fulfilled_count or 0)
local minus2 = (suggestion.minus2_unfulfilled_count  or 0)
    + (suggestion.minus2_fulfilled_count or 0)

local with_opinion = plus2 + plus1 + minus1 + minus2

local neutral = (suggestion.initiative.supporter_count or 0)
    - with_opinion

local neutral2 = with_opinion 
      - (suggestion.plus2_fulfilled_count or 0)
      - (suggestion.plus1_fulfilled_count or 0)
      - (suggestion.minus1_fulfilled_count or 0)
      - (suggestion.minus2_fulfilled_count or 0)


if with_opinion > 0 then
  ui.container { attr = { class = "suggestion-rating" }, content = function ()
    ui.tag { content = _"collective rating:" }
    slot.put("&nbsp;")
    ui.bargraph{
      max_value = suggestion.initiative.supporter_count,
      width = 100,
      bars = {
        { color = "#0a0", value = plus2 },
        { color = "#8a8", value = plus1 },
        { color = "#eee", value = neutral },
        { color = "#a88", value = minus1 },
        { color = "#a00", value = minus2 },
      }
    }
    slot.put(" | ")
    ui.tag { content = _"implemented:" }
    slot.put ( "&nbsp;" )
    ui.bargraph{
      max_value = with_opinion,
      width = 100,
      bars = {
        { color = "#0a0", value = suggestion.plus2_fulfilled_count },
        { color = "#8a8", value = suggestion.plus1_fulfilled_count },
        { color = "#eee", value = neutral2 },
        { color = "#a88", value = suggestion.minus1_fulfilled_count },
        { color = "#a00", value = suggestion.minus2_fulfilled_count },
      }
    }
  end }
end

