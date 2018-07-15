function ui.cell_full(args)
  args.attr = args.attr or {}
  args.attr.class = args.attr.class and args.attr.class .. " " or ""
  args.attr.class = args.attr.class .. "mdl-cell mdl-cell--12-col"
  ui.container(args)
end
