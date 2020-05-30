extends Node2D
var hand_1 = preload("res://sprites/1.png")
var hand_2 = preload("res://sprites/2.png")
var hand_3 = preload("res://sprites/3.png")
var hand_4 = preload("res://sprites/4.png")
var hand_5 = preload("res://sprites/5.png")
var hand_6 = preload("res://sprites/6.png")
var hand_7 = preload("res://sprites/7.png")
var hand_8 = preload("res://sprites/8.png")
var hand_9 = preload("res://sprites/9.png")
var hand_10 = preload("res://sprites/10.png")

var player_score = 0
var opp_score = 0
var over_count = 0
var over_max = 1
var ball_count = 0
var player_wickets_rem = 10
var opp_wickets_rem = 10
var max_wickets = 10
var balls_per_over = 6

var num_sides_batted_so_far = 0
var _player_batting
var _not_out = true
var _match_over = false

var player_overs = 0
var opp_overs = 0

func _ready():	
	print("base_game path = " + str(self.get_path()))
	num_sides_batted_so_far += 1
	over_max = get_node("/root/menu").no_overs
	print("over_max =" + str(over_max))
	print("get_node(\"/root/menu\").no_overs =  " + str(get_node("/root/menu").no_overs))
	$player.set_texture(hand_10)
	$opponent.set_texture(hand_10)
	$opponent.flip_h = true
	get_node("/root/menu/bg_music").playing = false
	
func _set_toss_decision():
	_player_batting = $coin_toss._player_batting
	print("base_game:38: coin_toss._player_batting = " + str($coin_toss._player_batting))
	print("base_game:39: _player_batting = " + str(_player_batting))

func _end_match():
	yield(get_tree().create_timer(1),"timeout")
	if _match_over:
		if player_score > opp_score:
			$you_won.visible = true
			$you_won/confetti.play("blow")
		elif player_score < opp_score:
			$they_won.visible = true
		else:
			$drawn.visible = true
	_update_labels()
			
func _final_action():
	queue_free()
	
func _check_if_won():
	if _player_batting and player_score > opp_score and num_sides_batted_so_far == 2:
		print("base_game:59: player has scored more than the opponent")
		_match_over = true
		_end_match()
	elif not _player_batting and opp_score > player_score and num_sides_batted_so_far == 2:
		print("base_game:62: opponent has scored more than the player")
		_match_over = true
		_end_match()
func _main_handler():
	if _player_batting:
		if _not_out:
			player_score += $button_array.instantaneous_score
			$PUMP/pump_up.set_text("")
			_update_labels()
			_check_if_won()
		else:
			if player_wickets_rem == 1:
				if num_sides_batted_so_far == 1:
					_switch_sides()
				else:
					_match_over = true
					_update_labels()
					_end_match()
			else:
				player_wickets_rem -= 1
				_update_labels()
			$PUMP/pump_up.set_text("OUT!")
			$PUMP/pump_up/AnimationPlayer.play("to_red")
			$special_event_sound.stream = load("res://audio/out_sound.wav")
			$special_event_sound.play()
			_not_out = true
	else:
		if _not_out:
			opp_score += $button_array.opponent_move
			$PUMP/pump_up.set_text("")
			_update_labels()
			_check_if_won()
		else:
			if opp_wickets_rem == 1:
				if num_sides_batted_so_far == 1:
					_switch_sides()
				else:
					_match_over = true
					_update_labels()
					_end_match()
			else:
				opp_wickets_rem -= 1
				_update_labels()
			$PUMP/pump_up.set_text("OUT!")
			$PUMP/pump_up/AnimationPlayer.play("to_red")
			$special_event_sound.stream = load("res://audio/out_sound.wav")
			$special_event_sound.play()
			_not_out = true

	if ball_count == 6*over_max:
		if num_sides_batted_so_far == 1:
			_switch_sides()
		else:
			_match_over = true
			_end_match()

func _reset_hands():
		$player.set_texture(hand_10)
		$opponent.set_texture(hand_10)
	
func _switch_sides():
	num_sides_batted_so_far += 1
	ball_count = 0
	over_count = 0
	if _player_batting == true:
		player_overs = str(ball_count/6) + str(ball_count%6)
	else:
		opp_overs = str(ball_count/6) + str(ball_count%6)
	_player_batting = not _player_batting
	yield(get_tree().create_timer(1),"timeout")
	$innings_over.visible = true
	_reset_hands()
	_clear_labels()

func _clear_labels():
	$PUMP/pump_up.set_text("Continue...")
	$my_stats/HBoxContainer/your_stat.set_text("")
	$my_stats/HBoxContainer/your_stat2.set_text("")
	$opp_stats/HBoxContainer/your_stat.set_text("")
	$opp_stats/HBoxContainer/your_stat2.set_text("")
	$ColorRect/misc_stats.set_text("Need " + str(abs(player_score-opp_score)+1) + " runs from " + str(over_max*6 - ball_count) + " balls to win.")
	
func _update_labels():
	if _player_batting:
		if player_score == 0 and opp_score == 0:
			$PUMP/pump_up.set_text("Begin!!!")
			$PUMP/pump_up/AnimationPlayer.play("to_green")
			$special_event_sound.stream = load("res://audio/six_sound.wav")
			$special_event_sound.play()
		elif $button_array.instantaneous_score == 1:
			$PUMP/pump_up.set_text(str($button_array.instantaneous_score) + " run")
		elif $button_array.instantaneous_score == 4:
			$PUMP/pump_up.set_text(str($button_array.instantaneous_score) + " runs!")
			$PUMP/pump_up/AnimationPlayer.play("to_yellow")
			$special_event_sound.stream = load("res://audio/four_sound.wav")
			$special_event_sound.play()
		elif $button_array.instantaneous_score == 6:
			$PUMP/pump_up.set_text(str($button_array.instantaneous_score) + " runs!!!")
			$PUMP/pump_up/AnimationPlayer.play("to_green")
			$special_event_sound.stream = load("res://audio/six_sound.wav")
			$special_event_sound.play()
		else:
			$PUMP/pump_up.set_text(str($button_array.instantaneous_score) + " runs")
		$my_stats/HBoxContainer/your_stat.set_text("You\n(Batting)")
		$opp_stats/HBoxContainer/your_stat.set_text("Opponent\n(Bowling)")
		$my_stats/HBoxContainer/your_stat2.set_text("Score: " + str(player_score) + "-" + str(max_wickets - player_wickets_rem))
		$opp_stats/HBoxContainer/your_stat2.set_text("Overs: " + str(ball_count/6) + "." + str(ball_count%6))
	else:
		if player_score == 0 and opp_score == 0:
			$PUMP/pump_up.set_text("Begin!!!")
			$PUMP/pump_up/AnimationPlayer.play("to_green")
			$special_event_sound.stream = load("res://audio/six_sound.wav")
			$special_event_sound.play()
		elif $button_array.opponent_move == 4:
			$PUMP/pump_up.set_text(str($button_array.opponent_move) + " runs!")
			$PUMP/pump_up/AnimationPlayer.play("to_yellow")
			$special_event_sound.stream = load("res://audio/four_sound.wav")
			$special_event_sound.play()
		elif $button_array.opponent_move == 6:
			$PUMP/pump_up.set_text(str($button_array.opponent_move) + " runs!!!")
			$PUMP/pump_up/AnimationPlayer.play("to_green")
			$special_event_sound.stream = load("res://audio/six_sound.wav")
			$special_event_sound.play()
		elif $button_array.opponent_move == 1:
			$PUMP/pump_up.set_text(str($button_array.opponent_move) + " run")
		else:
			$PUMP/pump_up.set_text(str($button_array.opponent_move) + " runs")
		$my_stats/HBoxContainer/your_stat.set_text("You\n(Bowling)")
		$opp_stats/HBoxContainer/your_stat.set_text("Opponent\n(Batting)")
		$my_stats/HBoxContainer/your_stat2.set_text("Overs: " + str(ball_count/6) + "." + str(ball_count%6))
		$opp_stats/HBoxContainer/your_stat2.set_text("Score: " + str(opp_score) + "-" + str(max_wickets - opp_wickets_rem))
	if num_sides_batted_so_far == 1:
		if _player_batting:
			if ball_count == 0:
				$ColorRect/misc_stats.set_text("Current runrate: -")
			else:
				print(str(ball_count/balls_per_over + 0.1*(ball_count%balls_per_over)))
				$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(player_score)/ball_count*balls_per_over,0.01)))
		else:
			if ball_count == 0:
				$ColorRect/misc_stats.set_text("Current runrate: -")
			else:
				print(str(ball_count/balls_per_over + 0.1*(ball_count%balls_per_over)))
				$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(opp_score)/ball_count*balls_per_over,0.01)))
	elif num_sides_batted_so_far == 2:
		if randi()%2 == 0:
			if not _match_over:
				$ColorRect/misc_stats.set_text("Need " + str(abs(player_score-opp_score)+1) + " runs from " + str(over_max*6 - ball_count) + " balls to win.")
			else:
				$ColorRect/misc_stats.set_text("Match finished!")
		else:
			if not _match_over:
				if _player_batting:
					if ball_count == 0 or ball_count == over_max*balls_per_over:
						$ColorRect/misc_stats.set_text("Current runrate: -")
					else:
						$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(player_score)/ball_count*balls_per_over,0.01)) + "\n required runrate: " + str(stepify(float(opp_score-player_score)/(balls_per_over*over_max-ball_count)*balls_per_over,0.01)))
				else:
					if ball_count == 0 or ball_count == over_max*balls_per_over:
						$ColorRect/misc_stats.set_text("Current runrate: -")
					else:
						$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(opp_score)/ball_count*balls_per_over,0.01)) + "\n required runrate: " + str(stepify(float(player_score-opp_score)/(balls_per_over*over_max-ball_count)*balls_per_over,0.01)))
			else:
				$ColorRect/misc_stats.set_text("Match finished!")
func _on_continue_pressed():
	_final_action()
	get_tree().change_scene("res://scenes/menu.tscn")

func _on_continue2_pressed():
	$innings_over.visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	$PUMP/pump_up.set("custom_colors/font_color", Color(1,1,1,1))
	$PUMP/pump_up.set("custom_fonts/font:size", str(50))
	print("animatiom finished")


func _on_Button_pressed():
	print("button pressed")
	if not _match_over and num_sides_batted_so_far == 2:
		print("match not over")
		if not "Current" in $ColorRect/misc_stats.get_text():
			print("current in misc_stats")
			if _player_batting:
				print("player batting")
				if ball_count == 0 or ball_count == over_max*balls_per_over:
					$ColorRect/misc_stats.set_text("Current runrate: -")
				else:
					print("printing current run rate")
					$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(player_score)/ball_count*balls_per_over,0.01)) + "\n required runrate: " + str(stepify(float(opp_score-player_score)/(balls_per_over*over_max-ball_count)*balls_per_over,0.01)))
			else:
				if ball_count == 0 or ball_count == over_max*balls_per_over:
					$ColorRect/misc_stats.set_text("Current runrate: -")
				else:
					$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(opp_score)/ball_count*balls_per_over,0.01)) + "\n required runrate: " + str(stepify(float(player_score-opp_score)/(balls_per_over*over_max-ball_count)*balls_per_over,0.01)))
		else:
			print("current not in misc_stats")
			$ColorRect/misc_stats.set_text("Need " + str(abs(player_score-opp_score)+1) + " runs from " + str(over_max*6 - ball_count) + " balls to win.")
	elif not _match_over and num_sides_batted_so_far == 1:
		print("match not over and num_sides is 1")
		if not "Current" in $ColorRect/misc_stats.get_text():
					print("current found in misc_stats")
					if _player_batting:
						if ball_count == 0:
							$ColorRect/misc_stats.set_text("Current runrate: -")
						else:
							print(str(ball_count/balls_per_over + 0.1*(ball_count%balls_per_over)))
							$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(player_score)/ball_count*balls_per_over,0.01)))
					else:
						if ball_count == 0:
							$ColorRect/misc_stats.set_text("Current runrate: -")
						else:
							print(str(ball_count/balls_per_over + 0.1*(ball_count%balls_per_over)))
							$ColorRect/misc_stats.set_text("Current runrate: " + str(stepify(float(opp_score)/ball_count*balls_per_over,0.01)))
		else:
			print("current not in misc_stats")
			$ColorRect/misc_stats.set_text("Odd or Even Hand Cricket")
	else:
		$ColorRect/misc_stats.set_text("Match finished!")
