open class Token {

    var content : String = ""
    var type : Int = 0
    var children : TokenStream = TokenStream.init()

    init(content: String, type: Int) {

        self.content = content
        self.type = type
    }

    convenience init(content: String) {
        
        self.init(content: content, type: 0)
    }

    convenience init(type: Int) {
        
        self.init(content: "", type: type)
    }
}