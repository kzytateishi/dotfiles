-- ウィンドウ配置の保存と復元
--   ⌃⌥⌘S: 今のウィンドウ配置を、今のディスプレイ構成用として保存する
--   ⌃⌥⌘L: 今のディスプレイ構成用の配置に並べ直す
--   ディスプレイを抜き差ししたら、その構成用の配置に自動で並べ直す
-- 配置は layouts.json に書く。~/.hammerspoon は dotfiles へのリンクなので、そのままコミットできる。
-- ウィンドウタイトルは保存しない (開いているファイル名やチャンネル名がリポジトリに残るため)。
-- 同じアプリのウィンドウが複数あるときは、前面にあるものから保存したときの順に割り当てる。

hs.window.animationDuration = 0

local layoutFile = hs.configdir .. "/layouts.json"
local hyper = { "ctrl", "alt", "cmd" }

local function round(n)
  return math.floor(n * 10000 + 0.5) / 10000
end

local function readLayouts()
  if not hs.fs.attributes(layoutFile) then return {} end
  return hs.json.read(layoutFile) or {}
end

-- 同じ名前のディスプレイ (Studio Display 2 台など) は左から順に #1, #2 を付けて区別する
local function screenIds()
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b)
    local fa, fb = a:frame(), b:frame()
    if fa.x ~= fb.x then return fa.x < fb.x end
    return fa.y < fb.y
  end)
  local ids, count = {}, {}
  for _, s in ipairs(screens) do
    local name = s:name() or "Unknown"
    count[name] = (count[name] or 0) + 1
    ids[#ids + 1] = { id = name .. " #" .. count[name], screen = s }
  end
  return ids
end

-- ディスプレイ構成ごとのキー (接続中のディスプレイを並べたもの)
local function configKey(ids)
  local names = {}
  for _, e in ipairs(ids) do names[#names + 1] = e.id end
  table.sort(names)
  return table.concat(names, " + ")
end

local function appKey(app)
  return app:bundleID() or app:name()
end

-- 現在のスペースにある通常のウィンドウ (前面から順)。フルスクリーンと最小化は対象外
local function targetWindows()
  local wins = {}
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:isStandard() and w:isVisible() and not w:isFullScreen() and w:application() then
      wins[#wins + 1] = w
    end
  end
  return wins
end

local function saveLayout()
  local ids = screenIds()
  local idOf = {}
  for _, e in ipairs(ids) do idOf[e.screen:id()] = e.id end

  local entries = {}
  for _, w in ipairs(targetWindows()) do
    local s = w:screen()
    local sf, f = s:frame(), w:frame()
    entries[#entries + 1] = {
      app = appKey(w:application()),
      screen = idOf[s:id()],
      -- ディスプレイ内の位置を 0〜1 の割合で持つ (解像度を変えても崩れない)
      rect = {
        x = round((f.x - sf.x) / sf.w),
        y = round((f.y - sf.y) / sf.h),
        w = round(f.w / sf.w),
        h = round(f.h / sf.h),
      },
    }
  end

  local key = configKey(ids)
  local layouts = readLayouts()
  layouts[key] = entries
  hs.json.write(layouts, layoutFile, true, true)
  hs.alert.show(("配置を保存しました (%d ウィンドウ)\n%s"):format(#entries, key))
end

local function applyLayout(auto)
  local ids = screenIds()
  local key = configKey(ids)
  local entries = readLayouts()[key]
  if not entries then
    if not auto then hs.alert.show("この構成の配置はまだ保存されていません (⌃⌥⌘S で保存)\n" .. key) end
    return
  end

  local screenOf = {}
  for _, e in ipairs(ids) do screenOf[e.id] = e.screen end
  local pending = {}
  for _, e in ipairs(entries) do
    pending[e.app] = pending[e.app] or {}
    table.insert(pending[e.app], e)
  end

  local moved = 0
  for _, w in ipairs(targetWindows()) do
    local list = pending[appKey(w:application())]
    local e = list and table.remove(list, 1)
    local s = e and screenOf[e.screen]
    if s then
      local sf = s:frame()
      w:setFrame({
        x = sf.x + e.rect.x * sf.w,
        y = sf.y + e.rect.y * sf.h,
        w = e.rect.w * sf.w,
        h = e.rect.h * sf.h,
      })
      moved = moved + 1
    end
  end
  hs.alert.show(("配置を復元しました (%d ウィンドウ)"):format(moved))
end

hs.hotkey.bind(hyper, "s", saveLayout)
hs.hotkey.bind(hyper, "l", function() applyLayout(false) end)

-- 抜き差しの直後はディスプレイの認識が揃わないので、変化が止んでから少し待って適用する。
-- watcher と timer はグローバルに置く (local だと GC で回収されて止まる)
layoutApplyTimer = nil
layoutScreenWatcher = hs.screen.watcher.new(function()
  if layoutApplyTimer then layoutApplyTimer:stop() end
  layoutApplyTimer = hs.timer.doAfter(3, function() applyLayout(true) end)
end):start()
