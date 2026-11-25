-- Offline check of wireplumber/wireplumber.conf.d/50-spotify-follow-default.conf.
-- Runs the rule through WirePlumber's own matcher; no audio service is touched.
-- Run through scripts/check-spotify-follow-default.sh, which passes the
-- config file's contents as wpexec's argument object (its Lua has no file I/O).
local rules = Json.Raw("[" .. (...):parse().conf .. "]")

local function restore(props)
  local out = JsonUtils.match_rules_update_properties(rules, Properties(props))
  return out["state.restore-target"]
end

local cases = {
  { "Spotify stream",  { ["application.name"] = "Spotify", ["media.class"] = "Stream/Output/Audio" }, "false" },
  { "Brave stream",    { ["application.name"] = "Brave" },   nil },
  { "VLC stream",      { ["application.id"] = "org.VideoLAN.VLC", ["application.name"] = "VLC media player" }, nil },
  { "Ardour stream",   { ["application.name"] = "Ardour" },  nil },
  { "Spotify-like name", { ["application.name"] = "Spotify Helper" }, nil },
}
local failures = {}
for _, c in ipairs(cases) do
  local got = restore(c[2])
  if tostring(got) ~= tostring(c[3]) then
    table.insert(failures, string.format("%s: state.restore-target=%s, want %s", c[1], tostring(got), tostring(c[3])))
  end
end
-- wpexec only surfaces Lua errors in its log, so failures are raised.
if #failures > 0 then
  error("CHECK FAILED: " .. table.concat(failures, "; "))
end
Core.quit()
