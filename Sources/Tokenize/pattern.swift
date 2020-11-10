

//PatternToken pattern
public class Pattern {
	
	public var type : Int
	public var content : String
	public var is_ignore_in_result : Bool
	public var can_nested : Bool
	public var export_type : Int

	public init(type: Int, content: String, is_ignore_in_result: Bool, can_nested: Bool, export_type: Int) {

		self.type = type 
		self.content = content
		self.is_ignore_in_result = is_ignore_in_result 
		self.can_nested = can_nested 
		self.export_type = export_type
	}

	//pattern define a token_type
    public convenience init(type: Int) {
		self.init(type: type, 
			content: "", 
			is_ignore_in_result: false, 
			can_nested: false, 
			export_type: 0)
	}
    
    //pattern define a token_type
    public convenience init(content: String) {
        
        self.init(type: 0,
            content: content,
            is_ignore_in_result: false,
            can_nested: false,
            export_type: 0)
    }

    public convenience init(type: Int, can_nested: Bool) {
        
		self.init(type: type, 
			content: "", 
			is_ignore_in_result: false, 
			can_nested: can_nested, 
			export_type: 0)
	}

    public convenience init(type: Int, is_ignore_in_result: Bool) {

		self.init(type: type, 
			content: "", 
			is_ignore_in_result: is_ignore_in_result, 
			can_nested: false, 
			export_type: 0)
	}

	//pattern define a token_type
    public convenience init(content: String, is_ignore_in_result: Bool) {
        
        self.init(type: 0,
            content: content,
            is_ignore_in_result: is_ignore_in_result,
            can_nested: false,
            export_type: 0)
    }
}

//Pattern define a pattern is a array of token type
public class PatternGroup {

	public var type : Int
	public var patterns : [Pattern]
	public var is_remove_global_ignore : Bool

	public init(type: Int, patterns: [Pattern], is_remove_global_ignore: Bool) {

		self.type = type
		self.patterns = patterns 
		self.is_remove_global_ignore = is_remove_global_ignore
	}
}
