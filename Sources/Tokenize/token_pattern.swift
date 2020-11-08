

//PatternToken pattern
public struct Pattern {
	public var type : Int
	public var content : String
	public var is_phrase_until : Bool
	public var is_ignore_in_result : Bool
	public var can_nested : Bool
	public var export_type : Int
}

//Pattern define a pattern is a array of token type
public struct PatternGroup {
	public var type : Int
	public var patterns : [Pattern]
	public var is_remove_global_ignore : Bool
}