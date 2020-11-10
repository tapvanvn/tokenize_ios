public struct RawTokenDefine {
    
    public init(type: Int, separate: Bool) {
        
        self.type = type
        self.separate = separate
    }
    
    public var `type` : Int // should be > 0
    public var separate: Bool //each char is separate token
}

open class RawMeaning : Meaning {
    
    var token_map : Dictionary<String, RawTokenDefine>// = Dictionary<String, RawTokenDefine>()
    var separate: Bool
    
    public init(token_map: Dictionary<String, RawTokenDefine>, separate: Bool) {
        
        self.token_map = token_map
        self.separate = separate
        
        super.init()
    }
    
    open override func prepare(content: String) {
        
        let raw_stream = TokenStream.init()

        raw_stream.tokenize(content: content)

        var cur_type : Int = 0

        let iter = raw_stream.iterator()

        var cur_content = ""
        
        while(!iter.eos) {
            
            let cur_token = iter.read()

            if let token = cur_token, let char = token.content.first {
                
                var found = false
                
                for pair in self.token_map {
                    
                    if pair.key.contains(char) {
                        
                        if cur_content.count > 0 && (cur_type != pair.value.type || pair.value.separate) {
                            
                            stream.addToken(token: Token.init(content: cur_content, type: cur_type))
                            
                            cur_content = ""
                        }

                        cur_content += String(char)

                        cur_type = pair.value.type

                        found = true
                        
                        break
                    }
                }
                
                if(!found) {

                    if(cur_type != 0 || self.separate) {
                        
                        stream.addToken(token: Token.init(content: cur_content, type: cur_type))
                        cur_content = ""
                    }
                    cur_content += String(char)
                    cur_type = 0
                }
            }
        }
        
        if(cur_content.count > 0) {
            
            stream.addToken(token: Token.init(content: cur_content, type: cur_type))
        }

        self.main_iter = stream.iterator()
    }
}
