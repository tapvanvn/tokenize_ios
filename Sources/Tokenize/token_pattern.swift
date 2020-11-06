

//PatternToken pattern
open struct Pattern {
	var type : Int
	var content : String
	var is_phrase_until : Bool
	var is_ignore_in_result : Bool
	var can_nested : Bool
	var export_type : Int
}

//Pattern define a pattern is a array of token type
open struct PatternGroup {
	var type : Int
	var patterns : [Pattern]
	var is_remove_global_ignore : Bool
}