function ui.cell_main(args)
  args.attr = args.attr or {}
  args.attr.class = args.attr.class and args.attr.class .. " " or ""
  args.attr.class = args.attr.class .. "mdl-cell mdl-cell--12-col mdl-cell--5-col-tablet mdl-cell--8-col-desktop mdl-cell--order-2-tablet mdl-cell--order-2-desktop"
  ui.container(args)
end
