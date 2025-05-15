extends Node

var camera: Camera2D
var world: Node2D
var player: Node2D
var ui: Control

func initialize(world_node, player_node, ui_node):
	self.world = world_node
	self.player = player_node
	self.camera = player_node.get_node("Camera2D")
	self.ui = ui_node

func create_echo_at(position, time_scale = 1.0):
	Entities.player.create_echo_at(position, time_scale)
