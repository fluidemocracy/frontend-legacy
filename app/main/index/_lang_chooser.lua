ui.tag{ tag = "button", attr = { id = "lf-lang-menu", class = "mdl-button mdl-js-button float-right" }, content = function()
  ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "language" }
  ui.tag{ tag = "i", attr = { class = "material-icons" }, content = "translate" }
end }

ui.tag { tag = "ul", attr = { class = "mdl-menu mdl-menu--bottom-right mdl-js-menu mdl-js-ripple-effect", ["data-mdl-for"] = "lf-lang-menu" }, content = function()
  for i, lang in ipairs(config.enabled_languages) do
    local langcode
    locale.do_with({ lang = lang }, function()
      langcode = _("[Name of Language]")
    end)
    ui.tag{ tag = "li", attr = { class = "mdl-menu__item" }, content = function()
      ui.link{
        content = langcode,
        attr = { class = "mdl-menu__link" },
        module = "index",
        action = "set_lang",
        params = { lang = lang },
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = request.get_id_string(),
            params = request.get_param_strings()
          }
        }
      }
    end }
  end
end }
