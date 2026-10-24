--#   ,-.       _,---._ __  / \
--#  /  )    .-'       `./ /   \
--# (  (   ,'            `/    /|
--#  \  `-"             \'\   / |
--#   `.              ,  \ \ /  |
--#    /`.          ,'-`----Y   |
--#   (            ;        |   '
--#   |  ,-.    ,-'         |  /
--#   |  | (   |   Meechie  | /
--#   )  |  \  `.___________|/
--[[
 ____  _____ _                  _
|  _ \|  ___| |_ _ __ __ _  ___| | _____ _ __
| |_) | |_  | __| '__/ _` |/ __| |/ / _ \ '__|
|  __/|  _| | |_| | | (_| | (__|   <  __/ |
|_|   |_|    \__|_|  \__,_|\___|_|\_\___|_|
]]
--================================================================================
-- PFtracker LUA - v0.5 Date: 2026-10-24
--================================================================================

_addon.name     = 'PFtracker'
_addon.author   = 'Meechie'
_addon.version  = '0.5'
_addon.commands = {'pf', 'PF', 'pftracker'}

-- ==[ Settings ]==============================================
local line_delay = 1.5
local auto_delay = 3
local fancy      = true
local auto       = false
local debug_on   = false

-- ==[ Colors ]================================================
local c_head  = 207
local c_num   = 220
local c_mob   = 158
local c_zone  = 160
local c_done  = 8
local c_dbg   = 123
local c_text  = 1

-- ==[ Foes ]==================================================
local foes = {
    {roe = 'I',    mob = 'Awoken Hildesvini',                         zone = 'Wajaom Woodlands (H-13)',           route = 'Unity warp (CL135) to Wajaom Woodlands, ride south'},
    {roe = 'II',   mob = 'Awoken Mokkuralfi',                         zone = 'Mount Zhayolm (I-10)',              route = 'Voidwatch warp to Mount Zhayolm'},
    {roe = 'III',  mob = 'Awoken Vampyr Jarl',                        zone = 'Caedarva Mire, Hediva Isle (I-6)',  route = 'Unity warp (CL135) to Caedarva Mire, ride north'},
    {roe = 'IV',   mob = 'Awoken Gorgimera',                          zone = 'Beaucedine Glacier (K-6)',          route = "HP to Fei'Yin, cast Escape (alt: Unity CL128 to Fei'Yin)"},
    {roe = 'V',    mob = 'Awoken Ariri Samariri',                     zone = 'Palborough Mines map 3 (G-10)',     route = 'HP #1 Palborough Mines'},
    {roe = 'VI',   mob = 'Awoken Hrungnir',                           zone = 'Aydeewa Subterrane map 2 (E-7)',    route = 'Survival Guide to Aydeewa Subterrane'},
    {roe = 'VII',  mob = 'Awoken Morbol Emperor',                     zone = 'Arrapago Reef map 3 (H-6)',         route = 'Survival Guide to Caedarva Mire, run east into Arrapago Reef'},
    {roe = 'VIII', mob = 'Awoken Stoorworm',                          zone = 'Reisenjima, Ethereal Ingress #9',   route = 'Dimensional Ring to Reisenjima, take Ethereal Ingress #9'},
    {roe = 'IX',   mob = 'Awoken Dendainsonne',                       zone = 'Western Altepa Desert (I-6)',       route = 'Unity warp (CL125) to W. Altepa, footprints NW of zone-in'},
    {roe = 'X',    mob = 'Awoken Freke',                              zone = 'Batallia Downs (J-7)',              route = 'HP Upper Jeuno #1, zone into Batallia, north of the road'},
    {roe = 'XI',   mob = 'Awoken Tanngrisnir',                        zone = 'Qufim Island (G-8)',                route = 'HP to Qufim Island'},
    {roe = 'XII',  mob = 'Awoken Nihhus',                             zone = 'Kamihr Drifts (F-8)',               route = "HP Ra'Kaznar Inner Court, cast Escape (alt: waypoint Outer Ra'Kaznar, exit east)"},
    {roe = 'XIII', mob = 'Awoken Hakenmann',                          zone = 'Rala Waterways (N-5)',              route = 'HP #1 Eastern Adoulin, enter Rala Waterways at (F-7)'},
    {roe = 'XIV',  mob = 'Awoken Andhrimnir',                         zone = 'Newton Movalpolos (L-9)',           route = 'HP #1 Newton Movalpolos, short walk'},
    {roe = 'XV',   mob = 'Awoken Angantyr, Hjorvarth, Hrani (all 3)', zone = 'Xarcabard (D-8)',                   route = 'HP Castle Zvahl Keep, cast Escape (alt: SG to Zvahl Baileys, walk out)'},
}

-- ==[ Lookup ]================================================
local roe_index = {}
for i, f in ipairs(foes) do
    roe_index[f.roe] = i
end

-- ==[ State ]=================================================
local last = 0
local done = {}

-- ==[ Local Chat ]============================================
local function col(n, s)
    return string.char(31, n) .. s
end

local function log(msg)
    windower.add_to_chat(c_text, col(c_head, '[PF] ') .. col(c_text, msg))
end

local function dbg(msg)
    if debug_on then
        windower.add_to_chat(c_text, col(c_dbg, '[PF dbg] ') .. col(c_text, msg))
    end
end

-- ==[ Party Chat ]============================================
local function use_fancy()
    return fancy and windower.to_shift_jis ~= nil
end

local function party(lines)
    local sjis = use_fancy()
    for i, line in ipairs(lines) do
        local out = sjis and windower.to_shift_jis(line) or line
        coroutine.schedule(function()
            windower.chat.input('/p ' .. out)
        end, 0.1 + (i - 1) * line_delay)
    end
end

-- ==[ Party Layouts ]=========================================
local function fancy_lines(n, f, tag)
    return {
        ('◆◇◆ %sPeculiar Foe %d/%d ◆◇◆'):format(tag, n, #foes),
        ('★ %s 【%s】'):format(f.mob, f.zone),
        ('→ %s'):format(f.route),
        ('※ RoE: set Peculiar Foes %s (Quests 4) before popping!'):format(f.roe),
    }
end

local function plain_lines(n, f, tag)
    return {
        ('=== %sPeculiar Foe %d/%d ==='):format(tag, n, #foes),
        ('>> %s [%s]'):format(f.mob, f.zone),
        ('-> %s'):format(f.route),
        ('!! RoE: set Peculiar Foes %s (Quests 4) before popping!'):format(f.roe),
    }
end

local function finished_line()
    return use_fancy() and '◆◇◆ All Peculiar Foes down! ◆◇◆' or '=== All Peculiar Foes down! ==='
end

-- ==[ Helpers ]===============================================
local function next_open(from)
    for step = 1, #foes do
        local i = (from + step - 1) % #foes + 1
        if not done[i] then
            return i
        end
    end
end

local function clean(s)
    return (s:gsub('[\30\31\127].', ''):gsub('[^\32-\126]', ''))
end

-- ==[ Commands ]==============================================
local function show(n, from_auto)
    local f = foes[n]
    local tag = from_auto and 'Next Up: ' or ''
    last = n
    party(use_fancy() and fancy_lines(n, f, tag) or plain_lines(n, f, tag))
end

local function list()
    windower.add_to_chat(c_text, col(c_head, '==== Peculiar Foes ===================='))
    for i, f in ipairs(foes) do
        if done[i] then
            windower.add_to_chat(c_text, col(c_done, ('%2d. %-5s%s  (done)'):format(i, f.roe, f.mob)))
        else
            windower.add_to_chat(c_text,
                col(c_num, ('%2d. %-5s'):format(i, f.roe)) ..
                col(c_mob, f.mob) ..
                col(c_zone, '  ' .. f.zone))
        end
    end
    windower.add_to_chat(c_text, col(c_head, '========================================'))
    log('Auto next: ' .. (auto and 'on' or 'off'))
end

local function toggle_style()
    fancy = not fancy
    log('Party style: ' .. (fancy and 'fancy' or 'plain'))
end

local function toggle_auto()
    auto = not auto
    log('Auto next: ' .. (auto and 'on' or 'off'))
end

local function toggle_debug()
    debug_on = not debug_on
    log('Debug: ' .. (debug_on and 'on' or 'off'))
end

local function reset()
    done = {}
    last = 0
    log('Progress cleared')
end

local function help()
    log(col(c_num, '//pf <1-15>') .. col(c_text, '  party: foe, route, RoE reminder'))
    log(col(c_num, '//pf next')   .. col(c_text, '    party: next foe not done yet'))
    log(col(c_num, '//pf list')   .. col(c_text, '    local: full order + done marks'))
    log(col(c_num, '//pf auto')   .. col(c_text, '    toggle auto post next foe on RoE complete'))
    log(col(c_num, '//pf style')  .. col(c_text, '   toggle fancy / plain party text'))
    log(col(c_num, '//pf reset')  .. col(c_text, '   clear done marks'))
    log(col(c_num, '//pf debug')  .. col(c_text, '   toggle detection output'))
end

-- ==[ RoE Complete ]==========================================
local function on_complete(roe)
    local i = roe_index[roe]
    if not i or done[i] then
        return
    end
    done[i] = true
    log(col(c_mob, foes[i].mob) .. col(c_text, ' done'))

    if not auto then
        return
    end

    local n = next_open(i)
    if n then
        last = n
        coroutine.schedule(function() show(n, true) end, auto_delay)
    else
        last = 0
        coroutine.schedule(function() party({finished_line()}) end, auto_delay)
    end
end

-- ==[ Events ]================================================
windower.register_event('incoming text', function(original)
    local s = clean(original)
    if not s:find('^%s*You have completed the following Records of Eminence') then
        return
    end
    local roe = s:match('Peculiar Foes ([IVX]+)')
    dbg('RoE complete seen, numeral: ' .. (roe or 'none'))
    if roe then
        on_complete(roe)
    end
end)

windower.register_event('addon command', function(cmd)
    cmd = (cmd or ''):lower()
    local n = tonumber(cmd)
    if n then
        if foes[n] then
            show(n)
        else
            log('Pick 1-' .. #foes)
        end
    elseif cmd == 'next' then
        local nx = next_open(last)
        if nx then
            show(nx)
        else
            log('All done. //pf reset to start over')
        end
    elseif cmd == 'list' then
        list()
    elseif cmd == 'auto' then
        toggle_auto()
    elseif cmd == 'style' then
        toggle_style()
    elseif cmd == 'reset' then
        reset()
    elseif cmd == 'debug' then
        toggle_debug()
    else
        help()
    end
end)
