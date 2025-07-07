class_name ClamCasino extends Node

var score: int = 0
var game_id: int = -1

func _ready():
	_fill_grid()

# create a new game session
func new_game():
	print("[INFO] A new game has been started!")
	self.score = 0
	
	# request new game from the server
	var request := HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(self._new_game_request_complete)
	request.request_completed.connect(request.queue_free.unbind(4))
	var error = request.request("http://127.0.0.1:5000/new", [], HTTPClient.METHOD_POST, "")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
	
# parses HTTP response and sets game ID
func _new_game_request_complete(result, response_code, headers, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS and response_code == 200:
		push_error("Could not complete the request. Server unreachable?")
	
	self.game_id = int(body.get_string_from_utf8())
	print("[INFO] New game ID: " + body.get_string_from_utf8())
	get_node("%LabelID").text = "game ID: " + str(game_id)
	get_node("%LabelScore").text = "score: " + str(score)

# fill the grid with cards
func _fill_grid():
	var bg: GridContainer = get_node("%BoardGrid")
	var card := preload("res://card.tscn")
	
	for row in range(5):
		for col in range(5):
			var new_card = card.instantiate()
			new_card.row = row
			new_card.col = col
			bg.add_child(new_card)
