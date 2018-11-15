--[[
	Mod ArmaTesla para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicialização de scripts
  ]]

-- Tabela Global
armatesla = {}

local modpath = minetest.get_modpath("armatesla")

dofile(modpath.."/tradutor.lua")

-- Tradutor de texto
local S = armatesla.S

-- Node de tesla
minetest.register_node("armatesla:tesla", {
	description = S("Armadilha de Tesla"),
	tiles = {"armatesla_top.png", "armatesla_top.png", "armatesla_sides.png"},
	paramtype2 = "facedir",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.3125, 0.125}, -- NodeBox1
			{-0.4375, -0.375, 0.125, 0.4375, 0.375, 0.4375}, -- NodeBox2
			{-0.4375, -0.375, -0.4375, 0.4375, 0.375, -0.125}, -- NodeBox4
			{0.125, -0.375, -0.4375, 0.4375, 0.375, 0.4375}, -- NodeBox5
			{-0.4375, -0.375, -0.4375, -0.125, 0.375, 0.4375}, -- NodeBox6
			{-0.375, -0.4375, -0.375, -0.25, 0.4375, 0.375}, -- NodeBox7
			{0.25, -0.4375, -0.375, 0.375, 0.4375, 0.375}, -- NodeBox8
			{-0.375, -0.4375, -0.375, 0.375, 0.4375, -0.25}, -- NodeBox9
			{-0.375, -0.4375, 0.25, 0.375, 0.4375, 0.375}, -- NodeBox11
			{-0.5, -0.25, -0.5, 0.5, 0.25, 0.5}, -- NodeBox12
		}
	},
	
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node,
	
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(2)
	end,
	
	-- Temporizador 
	on_timer = function(pos, elapsed)
		
		-- Verifica se emit som
		local s = false
		
		-- Verifica se está inibido
		local i = false
		
		-- Verifica inibidores
		do 
			local all_objects = minetest.get_objects_inside_radius(pos, 2)
			
			for _,obj in ipairs(all_objects) do
				local luaent = obj:get_luaentity() or {}
				if luaent.name == "armatesla:antitesla_entity_inibidora" then
					s = true
					i = true
					break
				end
			end
		end
		
		-- Pega objetos proximos
		if i == false then
		
			local all_objects = minetest.get_objects_inside_radius(pos, 8)
			local players = {} -- Jogadores na area
			for _,obj in ipairs(all_objects) do
				if obj:is_player() then
					table.insert(players, obj)
				end
			end
			
			-- Dar dano nos jogadores
			for _,p in ipairs(players) do
				-- Verifica se está visivel
				local pp = p:getpos()
				if minetest.line_of_sight({x=pos.x, y=pos.y+1, z=pos.z}, {x=pp.x, y=pp.y+1, z=pp.z}) == true then
					p:set_hp(p:get_hp()-10)
					s = true
				end
			end
		end
		
		-- Emitir som
		if s == true then
			minetest.sound_play("armatesla_shock", {
				pos = pos,
				max_hear_distance = 20,
				gain = 10.0,
			})
		end
		
		-- Repete o mesmo tempo
		return true
	end,
})

minetest.register_entity("armatesla:antitesla_entity_inibidora", {
	physical = true,
	timer = 0,
	visual = "cube",
	visual_size = {x=1/8, y=1/8},
	textures = {
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
	},
	player = nil,
	collisionbox = {-1/16,-1/16,-1/16, 1/16,1/16,1/16},
	on_activate = function(self, staticdata)
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 30 then
			self.object:remove() -- Remove particula lançada
		end
		-- Verifica se encontrou tesla
		if self.em_tesla == nil and self.timer >= 1 then
			local pos = self.object:getpos()
			if table.maxn(minetest.find_nodes_in_area(
				{x=pos.x-1, y=pos.y-1, z=pos.z-1}, {x=pos.x+1, y=pos.y+1, z=pos.z+1}, {"armatesla:tesla"})) == 0 then
				self.object:remove()
			else
				self.em_tesla = true
				local id = minetest.add_particlespawner(
					1000, 30, pos, pos,
					{x=-1, y=1, z=-1}, {x=1, y=1, z=1},
					{x=2, y=-2, z=-2}, {x=2, y=-2, z=2},
					0.1, 0.75, 1, 8, false, "armatesla_particula_antitesla.png"
				)
			end
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})

minetest.register_entity("armatesla:antitesla_entity", {
	physical = true,
	timer = 0,
	visual = "cube",
	visual_size = {x=1/8, y=1/8},
	textures = {
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
		"armatesla_antitesla_flare.png",
	},
	player = nil,
	collisionbox = {-1/16,-1/16,-1/16, 1/16,1/16,1/16},
	on_activate = function(self, staticdata)
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.2 then
			local pos = self.object:getpos()
			local below = {x=pos.x, y=pos.y - 1, z=pos.z}
			local node = minetest.get_node(below)
			if node.name ~= "air" then
				self.object:setvelocity({x=0, y=-10, z=0})
				self.object:setacceleration({x=0, y=0, z=0})
				if minetest.get_node(pos).name == "air" and
						node.name ~= "default:water_source" and
						node.name ~= "default:water_flowing" then
					local meta = minetest.get_meta(pos)
					pos.y = pos.y - 0.1
				end
				self.object:remove() -- Remove particula lançada
				local new_obj = minetest.add_entity(pos, "armatesla:antitesla_entity_inibidora")
				local lua_obj = new_obj:get_luaentity()
				lua_obj.name = "armatesla:antitesla_entity_inibidora"
			end
			-- Tempo limite
			self.timer_max = (self.timer_max or 0) + self.timer
			if self.timer_max >= 8 then
				self.object:remove()
				return
			end
			self.timer = 0
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})

-- Granada Antitesla
minetest.register_craftitem("armatesla:antitesla", {
	description = S("Granada AntiTesla"),
	inventory_image = "armatesla_granada_antitesla.png",
	on_use = function(itemstack, user, pointed_thing)
		local inv = user:get_inventory()
		minetest.sound_play("armatesla_granada_antitesla", {
			pos = user:getpos(),
			max_hear_distance = 10,
			gain = 10.0,
		})
		
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		local pos = user:getpos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_yaw()
		if pos and dir and yaw then
			pos.y = pos.y + 1.5
			local obj = minetest.add_entity(pos, "armatesla:antitesla_entity")
			if obj then
				obj:setvelocity({x=dir.x * 16, y=dir.y * 16, z=dir.z * 16})
				obj:setacceleration({x=dir.x * -3, y=-10, z=dir.z * -3})
				obj:setyaw(yaw + math.pi)
				local ent = obj:get_luaentity()
				if ent then
					ent.player = ent.player or user
				end
			end
		end
		return itemstack
	end,
})
