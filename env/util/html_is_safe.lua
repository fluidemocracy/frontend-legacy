function util.html_is_safe(str)

  -- All (ASCII) control characters except \t\n\f\r are forbidden:
  if string.find(str, "[\0-\8\11\14-\31\127]") then
    return false, "Invalid ASCII control character"
  end

  -- Memorize expected closing tags:
  local stack = {}

  -- State during parsing:
  local para    = false  -- <p> tag open
  local bold    = false  -- <b> tag open
  local italic  = false  -- <i> tag open
  local supsub  = false  -- <sup> or <sub> tag open
  local link    = false  -- <a href="..."> tag open
  local heading = false  -- <h1-6> tag open
  local list    = false  -- <ol> or <ul> (but no corresponding <li>) tag open
  local listelm = false  -- <li> tag (but no further <ol> or <ul> tag) open

  -- Function looped with tail-calls:
  local function loop(str)

    -- NOTE: We do not allow non-escaped "<" or ">" in attributes,
    --       even if HTML5 allows it.

    -- Find any "<" or ">" character and determine context, i.e.
    -- pre = text before character, tag = text until closing ">", and rest:
    local pre, tag, rest = string.match(str, "^(.-)([<>][^<>]*>?)(.*)")

    -- Disallow text content (except inter-element white-space) in <ol> or <ul>
    -- when outside <li>:
    if list and string.find(pre, "[^\t\n\f\r ]") then
      return false, "Text content in list but outside list element"
    end

    -- If no more "<" or ">" characters are found,
    -- then return true if all tags have been closed:
    if not tag then
      if #stack == 0 then
        return true
      else
        return false, "Not all tags have been closed"
      end
    end

    -- Handle (expected) closing tags:
    local closed_tagname = string.match(tag, "^</(.-)[\t\n\f\r ]*>$")
    if closed_tagname then
      closed_tagname = string.lower(closed_tagname)
      if closed_tagname ~= stack[#stack] then
        return false, "Wrong closing tag"
      end
      if closed_tagname == "p" then
        para = false
      elseif closed_tagname == "b" then
        bold = false
      elseif closed_tagname == "i" then
        italic = false
      elseif closed_tagname == "sup" or closed_tagname == "sub" then
        supsub = false
      elseif closed_tagname == "a" then
        link = false
      elseif string.find(closed_tagname, "^h[1-6]$") then
        heading = false
      elseif closed_tagname == "ul" or closed_tagname == "ol" then
        list = false
      elseif closed_tagname == "li" then
        listelm = false
        list = true
      end
      stack[#stack] = nil
      return loop(rest)
    end

    -- Allow <br> tag as void tag:
    if string.find(tag, "^<[Bb][Rr][\t\n\f\r ]*/?>$") then
      return loop(rest)
    end

    -- Parse opening tag:
    local tagname, attrs = string.match(
      tag,
      "^<([^<>\0-\32]+)[\t\n\f\r ]*([^<>]-)[\t\n\f\r ]*>$"
    )

    -- Return false if tag could not be parsed:
    if not tagname then
      return false, "Malformed tag"
    end

    -- Make tagname lowercase:
    tagname = string.lower(tagname)

    -- Append closing tag to list of expected closing tags:
    stack[#stack+1] = tagname

    -- Allow <li> tag in proper context:
    if tagname == "li" and attrs == "" then
      if not list then
        return false, "List element outside list"
      end
      list = false
      listelm = true
      return loop(rest)
    end

    -- If there was no valid <li> tag but <ol> or <ul> is open,
    -- then return false:
    if list then
      return false
    end

    -- Allow <b>, <i>, <sup>, <sub> unless already open:
    if tagname == "b" and attrs == "" then
      if bold then
        return false, "Bold inside bold tag"
      end
      bold = true
      return loop(rest)
    end
    if tagname == "i" and attrs == "" then
      if italic then
        return false, "Italic inside italic tag"
      end
      italic = true
      return loop(rest)
    end
    if (tagname == "sup" or tagname == "sub") and attrs == "" then
      if supsub then
        return false, "Super/subscript inside super/subscript tag"
      end
      supsub = true
      return loop(rest)
    end

    -- Allow <a href="..."> tag unless already open or malformed:
    if tagname == "a" then
      if link then
        return false, "Link inside link"
      end
      local url = string.match(attrs, '^[Hh][Rr][Ee][Ff][\t\n\f\r ]*=[\t\n\f\r ]*"([^"]*)"$')
      if not url then
        url = string.match(attrs, "^[Hh][Rr][Ee][Ff][\t\n\f\r ]*=[\t\n\f\r ]*'([^']*)'$")
      end
      if not url then
        url = string.match(attrs, "^[Hh][Rr][Ee][Ff][\t\n\f\r ]*=[\t\n\f\r ]*([^\0-\32\"'=<>`]+)$")
      end
      if not url then
       return false, "Forbidden, missing, or malformed attributes in link tag"
      end
      if not string.find(url, "^[Hh][Tt][Tt][Pp][Ss]?://") then
        return false, "Invalid link URL"
      end
      link = true
      return loop(rest)
    end

    -- Remaining tags require no open <p>, <b>, <i>, <sup>, <sub>,
    -- <a href="...">, or <h1>..</h6> tag:
    if para or bold or italic or supsub or link or heading then
      return false, "Forbidden child tag within paragraph, bold, italic, super/subscript, link, or heading tag"
    end

    -- Allow <p>:
    if tagname == "p" and attrs == "" then
      para = true
      return loop(rest)
    end

    -- Allow <h1>..<h6>:
    if string.find(tagname, "^h[1-6]$") and attrs == "" then
      heading = true
      return loop(rest)
    end

    -- Allow <ul> and <ol>:
    if (tagname == "ul" or tagname == "ol") and attrs == "" then
      list = true
      return loop(rest)
    end

    -- Disallow all others (including unexpected closing tags):
    return false, "Forbidden tag or forbidden attributes"

  end

  -- Invoke tail-call loop:
  return loop(str)

end
