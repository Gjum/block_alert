local playerRenamePos = {}

minetest.register_node("block_alert:notifier",
{
    description = "Notifier block.",
    tiles = {"^[colorize:#802BB1"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},

    after_place_node  = function(pos, placer)
        local meta = minetest.get_meta(pos)
        meta:mark_as_private("name")
        meta:set_string("name", "Notifier")
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local pname = clicker and clicker:get_player_name() or ""
        local meta = minetest.get_meta(pos)
        if(util.check_permission(pos,pname)) then 
            playerRenamePos[pname] = pos
            minetest.show_formspec(pname, "block_alert:notifier_rename", notifier.get_formspec(meta:get_string("name")))            
        end
    end
})

minetest.register_node("block_alert:recorder",
{
    description = "Recorder block.",
    tiles = {"^[colorize:#0000FF"},
    groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},

    after_place_node  = function(pos, placer)
        local meta = minetest.get_meta(pos)
        meta:mark_as_private("name")
        meta:mark_as_private("log")
        meta:set_string("name", "Recorder")
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local pname = clicker and clicker:get_player_name() or ""
        if(util.check_permission(pos,pname)) then
            minetest.show_formspec(pname, "block_alert:recorder_log", recorder.get_formspec(pos))            
        end
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "block_alert:notifier_rename" then
        return
    end

    if fields.name then
        local pname = player and player:get_player_name() or ""
        local meta = minetest.get_meta(playerRenamePos[pname])
        if(util.check_permission(playerRenamePos[pname],pname)) then
            meta:set_string("name", fields.name) 
        end
    end
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    if placer and minetest.is_player(placer) then recorder.handle_block_event(pos, newnode.name, placer:get_player_name(), "placed") end
    return false
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    if digger and minetest.is_player(digger) then recorder.handle_block_event(pos, oldnode.name, digger:get_player_name(), "broke") end
end)

pmutils.register_player_move(function(player,player_pos, player_last_pos)
    util.check_new_player_move(player)
end)