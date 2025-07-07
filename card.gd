class_name Card extends Button

var row := 0
var col := 0
var flipped := false
var value := -1

@onready var session: ClamCasino = get_tree().current_scene

func _pressed():
	# maybe improve the ergonomics of this later
	if flipped:
		return
	
	# boilerplate http request stuff
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._handle_request)
	http_request.request_completed.connect(http_request.queue_free.unbind(4))
	
	# make the request
	var url = "http://127.0.0.1:5000/flip/" + str(session.game_id)
	var headers = ["Content-Type: application/json"]
	var data = JSON.stringify({"row": str(row), "col": str(col)})
	http_request.request(url, headers, HTTPClient.METHOD_POST, data)
	
# card flip request handling
func _handle_request(result, response_code, headers, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS and response_code == 200:
		push_error("Request to flip card " + str(col) + ", " + str(row) + " failed.")
	
	print("[INFO] Flipping card " + str(col) + ", " + str(row) + "...")
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	self.value = response["card"]
	session.score = response["score"]
	print("[INFO] It was a " + str(value) + "!")
	
	var score_label: Label = session.get_child(2)
	score_label.text = "score: " + str(session.score)
