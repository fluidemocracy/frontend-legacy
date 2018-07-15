function ui.cell_sidebar(args)
  args.attr = args.attr or {}
  args.attr.class = args.attr.class and args.attr.class .. " " or ""
  args.attr.class = args.attr.class .. "mdl-cell mdl-cell--12-col mdl-cell--3-col-tablet mdl-cell--4-col-desktop mdl-cell--order-1-tablet mdl-cell--order-1-desktop"
  ui.container(args)
end
