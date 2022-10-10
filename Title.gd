extends Node2D

const WINDOW_WIDTH = 400;
const WINDOW_HEIGHT = 640;
const FONT_SIZE = 32;

func _draw():
	draw_rect(Rect2(0,0,WINDOW_WIDTH,WINDOW_HEIGHT),Color.darkgreen,true);
	
	$TitleLabel.set_position(Vector2(0,WINDOW_HEIGHT/4));
	$TitleLabel.set_size(Vector2(WINDOW_WIDTH,FONT_SIZE));
	$TitleLabel.align = Label.ALIGN_CENTER;
	$TitleLabel.valign = Label.ALIGN_CENTER;
	$TitleLabel.text = "お前が俺様のAIに\n勝てるわけねーだろハゲ";
	
	var margin_left = $SenteButton.margin_left;
	$SenteButton.set_position(Vector2(WINDOW_WIDTH/2+margin_left,WINDOW_HEIGHT/4*2));
	
	margin_left = $GoteButton.margin_left;
	$GoteButton.set_position(Vector2(WINDOW_WIDTH/2+margin_left,WINDOW_HEIGHT/4*3));

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			get_tree().quit();

func _on_SenteButton_pressed():
	Global.is_player_first = true;
	get_tree().change_scene("res://Main.tscn");


func _on_GoteButton_pressed():
	Global.is_player_first = false;
	get_tree().change_scene("res://Main.tscn");
