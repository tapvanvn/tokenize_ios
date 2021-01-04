open class TokenStream {

    var tokens : [Token] = []
    public init() {

    }
    //Length get len of stream
    public var length: Int {

        return tokens.count
    }

    public var content : String {

        let iter = iterator()

        var content = ""

        while (!iter.eos) {

            let token = iter.read()

            content += token!.content
        }

        return content
    }

    public func iterator() -> TokenStreamIterator {

        return TokenStreamIterator.init(stream: self)
    }

    public func addToken(token: Token) {

        tokens.append(token)
    }

    //Tokenize tokenize a string
    public func tokenize(content: String) {

        for character in content {

            let token = Token.init(content:String(character))

            addToken(token: token)
        }
    }

    public func tokenize(content:String, type:Int) {

        for character in content {

            let token = Token.init(content:String(character), type: type)

            addToken(token: token)
        }
    }
    
    public func printDebug(level: Int){

        let tab = [String].init(repeating: "-", count: level).joined()
        let iter = iterator()
        while !iter.eos {
            
            if let token = iter.read() {
                
                
                debugPrint("|-\(tab)\(token.type)_\(token.content)")
                
                if token.children.length > 0 {
                    
                    token.children.printDebug(level: level + 1)
                }
            }
        }
        
    }
}


