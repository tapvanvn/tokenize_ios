open class Token {

    public var content : String = ""
    public var type : Int = 0
    public var children : TokenStream = TokenStream.init()

    public init(content: String, type: Int) {

        self.content = content
        self.type = type
    }

    public convenience init(content: String) {
        
        self.init(content: content, type: 0)
    }

    public convenience init(type: Int) {
        
        self.init(content: "", type: type)
    }
}