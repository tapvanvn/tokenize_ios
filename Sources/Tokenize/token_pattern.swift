

//PatternToken pattern
public struct Pattern {
	public var type : Int
	public var content : String
	public var is_phrase_until : Bool
	public var is_ignore_in_result : Bool
	public var can_nested : Bool
	public var export_type : Int

	public init(type: Int, content: String, is_phrase_until: Bool, is_ignore_in_result: Bool, can_nested: Bool, export_type: Int) {

		self.type = type 
		self.content = content
		self.is_phrase_until = is_phrase_until
		self.is_ignore_in_result = is_ignore_in_result 
		self.can_nested = can_nested 
		self.export_type = export_type
	}
}

//Pattern define a pattern is a array of token type
public struct PatternGroup {
	public var type : Int
	public var patterns : [Pattern]
	public var is_remove_global_ignore : Bool

	public init(type: Int, patterns: [Pattern], is_remove_global_ignore: Bool) {

		self.type = type
		self.patterns = patterns 
		self.is_remove_global_ignore = is_remove_global_ignore
	}
}