
public class Mark {
    
	var type : Int
	var begin : Int
	var end  : Int
	var ignores: [Int] //iterator that should be ignore
	var can_nested : Bool
	var children : [Mark]
	var is_ignore_in_result : Bool
    
    public init(type: Int, begin: Int, end: Int, ignores: [Int], can_nested: Bool, children: [Mark], is_ignore_in_result: Bool) {

        self.type = type
        self.begin = begin
        self.end = end
        self.ignores = ignores
        self.can_nested = can_nested
        self.children = children
        self.is_ignore_in_result = is_ignore_in_result
    }
    
    public convenience init(type: Int, begin: Int, end: Int, ignores: [Int], children: [Mark]) {
        
        self.init(type: type, begin: begin, end: end, ignores: ignores, can_nested: false, children: children, is_ignore_in_result: false)
    }
    
    public convenience init(type: Int, can_nested: Bool, is_ignore_in_result: Bool) {
        
        self.init(type: type, begin: 0, end: 0, ignores: [], can_nested: can_nested, children: [], is_ignore_in_result: is_ignore_in_result )
    }
}
