public struct Mark {
	var type : Int
	var begin : Int
	var end  : Int
	var ignores: [Int] //iterator that should be ignore
	var can_nested : Bool
	var children : [Mark]
	var is_ignore_in_result : Bool
	var is_token_stream: Bool
}