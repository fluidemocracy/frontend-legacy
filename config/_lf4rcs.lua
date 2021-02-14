-- Configuration of lf4rcs
-- ------------------------------------------------------------------------
config.lf4rcs = {}

-- Example configuration for controlling a Git repository

config.lf4rcs.git = {
  
  render_draft_reference = function(url, draft)
    if not draft.external_reference then return end
    ui.tag{ content = _"Changeset:" }
    slot.put(" ")
    ui.link{
      text = draft.external_reference,
      external = url .. ";a=commit;h=" .. draft.external_reference
    }
  end,
  
  get_remote_user = function()
    return os.getenv("REMOTE_USER")
  end,
  
  get_branches = function(path, exec)
    local branches = {}
    for line in io.lines() do
      local oldrev, newrev, branch = string.match(line, "([^ ]+) ([^ ]+) refs/heads/(.+)")
      if not branch then
        return nil, "unexpected format from git hook environment"
      end
      branches[branch] = { newrev }
    end
    return branches
  end,
  
  commit = function(path, exec, branch, target_node_id, close_message, merge_message)
    if merge_message then
      exec("git", "-C", path, "checkout", "-f", "master")
      exec("git", "-C", path, "merge", target_node_id, "-m", merge_message)
      exec("git", "-C", path, "push", "origin", "master")
    end
  end

}

-- Example configuration for controlling a Mercurial repository
config.lf4rcs.hg = {

  working_branch_name = "work",

  render_draft_reference = function(url, draft)
    if not draft.external_reference then return end
    ui.tag{ content = _"Changeset graph:" }
    slot.put(" ")
    ui.link{
      text = draft.external_reference,
      external = url .. "/graph/" .. draft.external_reference
    }
  end,
  
  get_remote_user = function()
    return os.getenv("REMOTE_USER")
  end,
  
  get_branches = function(path, exec)
    local first_node_id = os.getenv("HG_NODE")
    if not first_node_id then
      return nil, "internal error, no first node ID available"
    end
    local hg_log = exec(
      "hg", "log", "-R", path, "-r", first_node_id .. ":", "--template", "{branches}\n"
    )
    local branches = {}
    for branch in hg_log:gmatch("(.-)\n") do
      if branch == "" then branch = "default" end
      if not branches[branch] then
        branches[branch] = {}
        local head_lines = exec(
          "hg", "heads", "-R", path, "--template", "{node}\n", branch
        )
        for node_id in string.gmatch(head_lines, "[^\n]+") do
          table.insert(branches[branch], node_id)
        end
      end
    end
    return branches
  end,

  extra_checks = function(path, exec)
    local result = exec("hg", "heads", "-t", "-c")
    for branch in string.gmatch(result, "[^\n]+") do
      if branch == lf4rcs.config.hg.working_branch_name then
        return nil, "open head found for branch " .. lf4rcs.config.hg.working_branch_name
      end
    end
    return true
  end,

  commit = function(path, exec, branch, target_node_id, close_message, merge_message)
    exec("hg", "up", "-R", path, "-C", "-r", target_node_id)
    exec("hg", "commit", "-R", path, "--close-branch", "-m", close_message)
    if merge_message then
      exec("hg", "up", "-R", path, "-C", "-r", "default")
      exec("hg", "merge", "-R", path, "-r", "tip")
      exec("hg", "commit", "-R", path, "-m", merge_message)
    end
  end
  
}

-- Grace period after creating an initiative for pushing changes during verification phase
-- disabled by default (nil), use PostgreSQL interval notation
-- config.lf4rcs.push_grace_period = nil

lf4rcs.init()

