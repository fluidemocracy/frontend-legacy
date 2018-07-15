ui.title(_"About site")

ui.grid{ content = function()
  ui.cell_full{ content = function()

    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()

      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"This service is provided by:" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()
        slot.put(config.app_service_provider)
      end }
    end }
        
    ui.container { attr = { class = "mdl-card mdl-shadow--2dp mdl-card__fullwidth" }, content = function()
      ui.container{ attr = { class = "mdl-card__title mdl-card--border" }, content = function()
        ui.heading { attr = { class = "mdl-card__title-text" }, level = 2, content = _"This service is provided using the following software components:" }
      end }
      ui.container{ attr = { class = "mdl-card__content mdl-card--border" }, content = function()

        local tmp = {
          {
            name = "LiquidFeedback Frontend",
            url = "http://www.public-software-group.org/liquid_feedback",
            version = config.app_version,
            license = "MIT/X11",
            license_url = "http://www.public-software-group.org/licenses"
          },
          {
            name = "LiquidFeedback Core",
            url = "http://www.public-software-group.org/liquid_feedback",
            version = db:query("SELECT * from liquid_feedback_version;")[1].string,
            license = "MIT/X11",
            license_url = "http://www.public-software-group.org/licenses"
          },
          {
            name = "WebMCP",
            url = "http://www.public-software-group.org/webmcp",
            version = WEBMCP_VERSION or _WEBMCP_VERSION,
            license = "MIT/X11",
            license_url = "http://www.public-software-group.org/licenses"
          }
        }
        
        if _MOONBRIDGE_VERSION then
          tmp[#tmp+1] = {
            name = "Moonbridge",
            url = "http://www.public-software-group.org/moonbridge",
            version = _MOONBRIDGE_VERSION,
            license = "MIT/X11",
            license_url = "http://www.public-software-group.org/licenses"
          }
        end
        
        tmp[#tmp+1] = {
          name = "Lua",
          url = "http://www.lua.org",
          version = _VERSION:gsub("Lua ", ""),
          license = "MIT/X11",
          license_url = "http://www.lua.org/license.html"
        }
        
        tmp[#tmp+1] = {
          name = "PostgreSQL",
          url = "http://www.postgresql.org/",
          version = db:query("SELECT version();")[1].version:gsub("PostgreSQL ", ""):gsub("on.*", ""),
          license = "PostgreSQL License",
          license_url = "http://www.postgresql.org/about/licence"
        }

        ui.list{
          records = tmp,
          columns = {
            {
              content = function(record) 
                ui.link{
                  content = record.name,
                  external = record.url
                }
              end
            },
            {
              content = function(record) ui.field.text{ value = record.version } end
            },
            {
              content = function(record) 
                ui.link{
                  content = record.license,
                  external = record.license_url
                }
              end

            }
          }
        }

        slot.put("<br />")
        ui.container{ content = "3rd party license information:" }
        slot.put('Some of the icons used in Liquid Feedback are from <a href="http://www.famfamfam.com/lab/icons/silk/">Silk icon set 1.3</a> by Mark James. His work is licensed under a <a href="http://creativecommons.org/licenses/by/2.5/">Creative Commons Attribution 2.5 License.</a>')
      end }
    end }
  end }
end }
