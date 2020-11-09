open class Meaning {

    public enum BasicTokenType : Int {

        case unknown = 0
        case word = 1
        case space = 2
        case `operator` = 3
        case phrase_break = 4
    }
    
    public var stream:TokenStream = TokenStream.init()

    public var main_iter: TokenStreamIterator!

    public init(unsafe_stream:TokenStream) {
        
        self.stream = unsafe_stream
        self.main_iter = self.stream.iterator()
    }
    
    public init( source : Meaning) {
        
        var token = source.next()
        
        while(token != nil) {
            
            stream.addToken(token: token!)
            token = source.next()
        }
    }
    
    public init(content: String, operators: String, spaces: String) {

        let raw_stream = TokenStream.init()

        raw_stream.tokenize(content: content)

        var cur_type : BasicTokenType = .unknown

        let iter = raw_stream.iterator()

        var cur_content = ""
        
        while(!iter.eos) {
            
            let cur_token = iter.read()

            if let token = cur_token, let char = token.content.first {
                
                if operators.contains(char) {
                    
                    if cur_type != .unknown {
                        
                        stream.addToken(token: Token.init(content: cur_content, type: cur_type.rawValue))
                    }
                    cur_content = String(char)

                    cur_type = .operator

                } else if spaces.contains(char) {

                    if cur_type != .unknown {

                        stream.addToken(token: Token.init(content: cur_content, type: cur_type.rawValue))
                    }
                    cur_content = ""

                    cur_type = .space

                } else {

                    if cur_type != .word && cur_type != .unknown {

                        stream.addToken(token: Token.init(content: cur_content, type: cur_type.rawValue))

                        cur_content = ""
                    }
                    cur_content += String(char)

                    cur_type = .word
                }
            }
        }

        if cur_type != .unknown {

            stream.addToken(token: Token.init(content: cur_content, type: cur_type.rawValue))
        }

        self.main_iter = stream.iterator()
    }
    
    public convenience init(content: String, operators: String) {

        self.init(content: content, operators: operators, spaces: "")
    }

    open func next()-> Token? {

        return main_iter.read()
    }
}
