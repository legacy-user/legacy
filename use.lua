script_properties('work-in-pause')
sampev = require('samp.events')
local effil = require('effil')
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8

local chatID = '1239573440'
local token = '7821635845:AAHTonSkccJoz7KcANzd7jq8jvOvX0xqMho'

local effilTelegramSendMessage = effil.thread(function(text)
    local requests = require('requests')
    requests.post(('https://api.telegram.org/bot%s/sendMessage'):format(token), {
        params = {
            text = text,
            chat_id = chatID,
        }
    })
end)

function url_encode(text)
    return text:gsub("([^%w%-_%.~=])", function(c)
        return string.format("%%%02X", string.byte(c))
    end):gsub(" ", "+")
end

function formatMoney(amount)
    local formatted = tostring(amount)
    local k = 0
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function sendTelegramMessage(text)
    local cleanText = text:gsub('{......}', '')
    effilTelegramSendMessage(url_encode(u8(cleanText)))
end

function sendUserInfoFinal()
    local result, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if not result then return end

    local nick = sampGetPlayerNickname(playerId) or "Неизвестно"
    local serverName = sampGetCurrentServerName() or "Неизвестно"
    local hp = getCharHealth(PLAYER_PED) or 0
    local armor = getCharArmour(PLAYER_PED) or 0
    local money = getPlayerMoney() or 0

    local message = string.format(
        "Информация о пользователе:\n- Ник: %s\n- ID: %d\n- Сервер: %s\n- Здоровье: %.1f\n- Броня: %.1f\n- Деньги: $%s",
        nick, playerId, serverName, hp, armor, formatMoney(money)
    )

    sendTelegramMessage(message)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage('[telegram] {ffffff}Активация отправки информации : /tg', 0x3083ff)
    sampRegisterChatCommand("tg", sendUserInfoFinal)

    while true do wait(0) end
end
