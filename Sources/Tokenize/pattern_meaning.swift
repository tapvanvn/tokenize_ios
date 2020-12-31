open class PatternMeaning : Meaning {
    
    var pattern_groups: [PatternGroup] = []
    var global_can_nested: [Int] = []
    
    var is_ignore_func: (Int)->Bool = {
        _ in return false
    }
    
    /*public init(content:String, operators: String, spaces:String, pattern_groups:[PatternGroup], is_ignore_func: @escaping (Int)->Bool) {

        super.init(content: content, operators: operators, spaces: spaces)
        
        self.pattern_groups = pattern_groups
        self.is_ignore_func = is_ignore_func

    }*/
    
    public init(stream: TokenStream, pattern_groups:[PatternGroup], is_ignore_func: @escaping (Int)->Bool) {
        
        super.init(unsafe_stream: stream)
        
        self.pattern_groups = pattern_groups
        self.is_ignore_func = is_ignore_func
    }
    
    public init(source: Meaning, pattern_groups:[PatternGroup], is_ignore_func: @escaping (Int)->Bool) {
        
        super.init(source: source)
        self.pattern_groups = pattern_groups
        self.is_ignore_func = is_ignore_func
    }

    convenience init(source: Meaning, pattern_groups:[PatternGroup], is_ignore_func: @escaping (Int)->Bool, global_can_nested: [Int]) {

        self.init(source: source, pattern_groups: pattern_groups, is_ignore_func: is_ignore_func)
        self.global_can_nested = global_can_nested
    }
    
    open override func next ()->Token?{
        
        while( !main_iter.eos) {
            
            let marks = main_iter.findPattern(pattern_groups: pattern_groups, stop_when_found: true, is_ignore: is_ignore_func)
            
            if marks.count > 0 {
                
                let mark = marks.first!
                
                let cur_token = Token.init(type: mark.type)
                
                for child_mark in mark.children {
                    
                    if child_mark.is_ignore_in_result {
                        
                        continue
                    }
                    
                    let child_token = main_iter.maskedToken(mark: child_mark, ignore_offsets: mark.ignores)
                    
                    
                    
                    if child_token != nil && child_mark.can_nested {
                        
                        let child_meaning = PatternMeaning.init(stream: child_token!.children, pattern_groups: self.pattern_groups, is_ignore_func: self.is_ignore_func)
                        
                        let sub_stream = TokenStream.init()
                        
                        while(true) {
                            
                            let nested_token = child_meaning.next()
                            
                            if nested_token == nil {
                                break
                            }
                            sub_stream.addToken(token: nested_token!)
                        }
                        
                        child_token!.children = sub_stream
                    }
                    
                    if child_token != nil {

                        cur_token.children.addToken(token: child_token!)

                    } else {
 
                        //meaning.Iterator.DebugMark(0, &patternMark, &patternMark.Ignores, js.TokenName)

                        //meaning.Iterator.DebugMark(1, m, &patternMark.Ignores, js.TokenName)
                    }
                }
                
                main_iter.seek(to: mark.end)
                
                return cur_token
                
            } else { // case no mark found
                
                if let normal_token = main_iter.read() {

                    if normal_token.children.length > 0 && global_can_nested.contains(normal_token.type) {

                        let child_meaning = PatternMeaning.init(stream: normal_token.children, pattern_groups: self.pattern_groups, is_ignore_func: self.is_ignore_func)
                            
                        let sub_stream = TokenStream.init()
                        
                        while(true) {
                            
                            let nested_token = child_meaning.next()
                            
                            if nested_token == nil {
                                break
                            }
                            sub_stream.addToken(token: nested_token!)
                        }
                        normal_token.children = sub_stream
                    }

                    return normal_token
                }
            }
        }
        return nil
    }
}
