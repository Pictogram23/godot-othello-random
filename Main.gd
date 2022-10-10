extends Node2D

const WINDOW_WIDTH = 400;
const WINDOW_HEIGHT = 640;
const BOARD_WIDTH = 400;
const BOARD_HEIGHT = 400;
const ROWS = 8;
const COLUMNS = 8;
const LINE_WIDTH = 2;
const TILE_SIZE = 50;
const DISC_RADIUS = 20;
const FONT_SIZE = 32;

var board = [];
var turn = DiscState.Black;
var count_black = 0;
var count_white = 0;
var game_over = false;
var is_player_turn = true;

enum DiscState {
	None,
	Black,
	White,
}

func _ready():
	var margin_left = $BackTitleButton.margin_left;
	$BackTitleButton.set_position(Vector2(BOARD_WIDTH/2+margin_left,BOARD_HEIGHT+(WINDOW_HEIGHT-BOARD_HEIGHT)/3*2));
	reset();
	
func _draw():
	draw_rect(Rect2(0,0,WINDOW_WIDTH,WINDOW_HEIGHT),Color.darkgreen,true);
	
	for i in range(ROWS+1):
		draw_rect(Rect2(-1+i*TILE_SIZE,0,LINE_WIDTH,BOARD_HEIGHT),Color.white,true);
	for i in range(COLUMNS+1):
		draw_rect(Rect2(0,-1+i*TILE_SIZE,BOARD_WIDTH,LINE_WIDTH),Color.white,true);
		
	for i in range(ROWS):
		for j in range(COLUMNS):
			match board[i][j]:
				DiscState.Black:
					draw_circle(Vector2(i*TILE_SIZE+TILE_SIZE/2,j*TILE_SIZE+TILE_SIZE/2),DISC_RADIUS,Color.black);
				DiscState.White:
					draw_circle(Vector2(i*TILE_SIZE+TILE_SIZE/2,j*TILE_SIZE+TILE_SIZE/2),DISC_RADIUS,Color.white);
	
	$BlackCountLabel.set_position(Vector2(8,BOARD_HEIGHT+8));
	$BlackCountLabel.text = "黒：%d" % count_black;
	
	$WhiteCountLabel.set_position(Vector2(-8,BOARD_HEIGHT+8));
	$WhiteCountLabel.set_size(Vector2(BOARD_WIDTH,FONT_SIZE));
	$WhiteCountLabel.align = Label.ALIGN_RIGHT;
	$WhiteCountLabel.text = "白：%d" % count_white;
	
	$GameStateLabel.set_position(Vector2(0,BOARD_HEIGHT+(WINDOW_HEIGHT-BOARD_HEIGHT)/3),false);
	$GameStateLabel.set_size(Vector2(BOARD_WIDTH,FONT_SIZE));
	$GameStateLabel.align = Label.ALIGN_CENTER;
	$GameStateLabel.valign = Label.ALIGN_CENTER;
	match game_over:
		false:
			match turn:
				DiscState.Black:
					$GameStateLabel.add_color_override("font_color", Color.black);
					$GameStateLabel.text = "黒のターンです";
				DiscState.White:
					$GameStateLabel.add_color_override("font_color", Color.white);
					$GameStateLabel.text = "白のターンです";
		true:
			$GameStateLabel.add_color_override("font_color", Color.yellow);
			if count_black > count_white:
				$GameStateLabel.text = "黒の勝ちです";
			elif count_black < count_white:
				$GameStateLabel.text = "白の勝ちです";
			else:
				$GameStateLabel.text = "引き分けです";

func _process(delta):
	if is_player_turn == false:
		var x = rand_range(0,8);
		var y = rand_range(0,8);
		reverse(Vector2(x,y),true);
		turn_manage();

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			get_tree().quit();
	if game_over == false and is_player_turn == true:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				var pos = (event.position / TILE_SIZE).floor();
				if pos.x < 0 or 8 <= pos.x or pos.y < 0 or 8 <= pos.y:
					return;
				reverse(Vector2(pos.x, pos.y), true);
				turn_manage();

func _on_BackTitleButton_pressed():
	get_tree().change_scene("res://Title.tscn");

func reset():
	game_over = false;
	turn = DiscState.Black;
	count_black = 0;
	count_white = 0;
	is_player_turn = Global.is_player_first;
	board.clear();
	for i in range(ROWS):
		var row = [];
		for j in range(COLUMNS):
			if (i == 3 or i == 4) and (j == 3 or j == 4):
				if i == j:
					row.append(DiscState.White);
					count_white += 1;
				else:
					row.append(DiscState.Black);
					count_black += 1;
			else:
				row.append(DiscState.None);
		board.append(row);
	update();

func turn_change():
	is_player_turn = !is_player_turn;
	match turn:
		DiscState.Black:
			turn = DiscState.White;
		DiscState.White:
			turn = DiscState.Black;

func turn_manage():
	for k in range(2):
		count_black = 0;
		count_white = 0;
		var isReversible = false;
		for i in range(ROWS):
			for j in range(COLUMNS):
				match board[i][j]:
					DiscState.Black:
						count_black += 1;
					DiscState.White:
						count_white += 1;
				var count_reversible = reverse(Vector2(i,j),false);
				if count_reversible > 0:
					isReversible = true;
		if isReversible == true:
			break;
		else:
			turn_change();
			if k == 1:
				game_over = true;

func reverse(pos:Vector2, isReverse:bool) -> int:
	var total_count_reversibles = 0;
	if board[pos.x][pos.y] == DiscState.None:
		for i in range(-1,2):
			for j in range(-1,2):
				if i == 0 and j == 0:
					continue;
				var tmp_row_index = pos.x + i;
				var tmp_column_index = pos.y + j;
				var count_reversibles = 0;
				
				while true:
					if tmp_row_index < 0 or ROWS <= tmp_row_index or tmp_column_index < 0 or COLUMNS <= tmp_column_index:
						count_reversibles = 0; 
						break;
					if board[tmp_row_index][tmp_column_index] == DiscState.None:
						count_reversibles = 0;
						break;
					if board[tmp_row_index][tmp_column_index] == turn:
						if isReverse == true:
							for k in range(count_reversibles):
								board[pos.x+i*(k+1)][pos.y+j*(k+1)] = turn;
						break;
					tmp_row_index += i;
					tmp_column_index += j;
					count_reversibles += 1;
				total_count_reversibles += count_reversibles;
													
		if isReverse == true and total_count_reversibles > 0:
			board[pos.x][pos.y] = turn;
			turn_change();
			update();
	return total_count_reversibles;
