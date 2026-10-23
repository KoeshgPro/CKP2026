extends Node2D

var rows_container: VBoxContainer

func _ready() -> void:
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	rows_container = VBoxContainer.new()
	rows_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	scroll.add_child(rows_container)
	
	if has_node("PanelContainer"):
		$PanelContainer.add_child(scroll)
	else:
		add_child(scroll)
		
	if not AcountSystem.leaderboard_loaded.is_connected(_on_data_arrived):
		AcountSystem.leaderboard_loaded.connect(_on_data_arrived)
	
	AcountSystem.get_top_scores()

func _on_data_arrived(top_players: Array) -> void:
	if not rows_container:
		return
		
	for child in rows_container.get_children():
		child.queue_free()
	
	var custom_font = load("res://ASSETS/UI/FONTS/PixelAE-Regular.ttf")
	var rank = 1
	
	for player in top_players:
		if player is Dictionary and player.has("player_name") and player.has("score"):
			var row_panel = PanelContainer.new()
			var hbox = HBoxContainer.new()
			
			var rank_lbl = Label.new()
			var name_lbl = Label.new()
			var score_lbl = Label.new()
			
			if custom_font:
				rank_lbl.add_theme_font_override("font", custom_font)
				name_lbl.add_theme_font_override("font", custom_font)
				score_lbl.add_theme_font_override("font", custom_font)
			
			rank_lbl.add_theme_font_size_override("font_size", 32)
			name_lbl.add_theme_font_size_override("font_size", 32)
			score_lbl.add_theme_font_size_override("font_size", 32)
			
			name_lbl.text_direction = Control.TEXT_DIRECTION_AUTO
			
			rank_lbl.text = "  " + str(rank) + "  "
			name_lbl.text = str(player["player_name"])
			score_lbl.text = str(player["score"])
			
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			name_lbl.modulate = Color.WHITE
			score_lbl.modulate = Color.WHITE
			
			if rank == 1:
				rank_lbl.modulate = Color("FFD700")
			elif rank == 2:
				rank_lbl.modulate = Color("C0C0C0")
			elif rank == 3:
				rank_lbl.modulate = Color("CD7F32")
			else:
				rank_lbl.modulate = Color.WHITE
			
			hbox.add_child(rank_lbl)
			hbox.add_child(name_lbl)
			hbox.add_child(score_lbl)
			row_panel.add_child(hbox)
			rows_container.add_child(row_panel)
			
			rank += 1

func _on_refresh_button_pressed() -> void:
	AcountSystem.get_top_scores()
