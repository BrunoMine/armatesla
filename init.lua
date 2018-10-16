--[[
	Mod ArmaTesla para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicialização de scripts
  ]]

-- Tabela Global
anarquia = {}

local modpath = minetest.get_modpath("armatesla")

--dofile(modpath.."/tradutor.lua")

-- Node de tesla
minetest.register_node("armatesla:tesla", {
	description = "Armadilha de Tesla",
	tiles = {"armatesla_top.png", "armatesla_top.png", "armatesla_sides.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node,
	
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(2)
	end,
	
	-- Temporizador 
	on_timer = function(pos, elapsed)
		
		-- Pega objetos proximos
		local all_objects = minetest.get_objects_inside_radius(pos, 8)
		local players = {} -- Jogadores na area
		for _,obj in ipairs(all_objects) do
			if obj:is_player() then
				table.insert(players, obj)
			end
		end
		
		-- Dar dano nos jogadores
		local s = false
		for _,p in ipairs(players) do
			-- Verifica se está visivel
			local pp = p:getpos()
			if minetest.line_of_sight({x=pos.x, y=pos.y+1, z=pos.z}, {x=pp.x, y=pp.y+1, z=pp.z}) == true then
				p:set_hp(p:get_hp()-10)
				s = true
			end
		end
		
		-- Emitir som
		if s == true then
			minetest.sound_play("armatesla_shock", {
				pos = pos,
				max_hear_distance = 10,
				gain = 10.0,
			})
		end
		
		-- Repete o mesmo tempo
		return true
	end,
})
