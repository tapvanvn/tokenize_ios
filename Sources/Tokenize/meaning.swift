open class Meaning {
    
    public var source: Meaning? = nil
    
    public var stream:TokenStream = TokenStream.init()

    public var main_iter: TokenStreamIterator!

    public init(){
        
        self.main_iter = self.stream.iterator()
    }
    
    public init(unsafe_stream:TokenStream) {
        
        self.stream = unsafe_stream
        self.main_iter = self.stream.iterator()
    }
    
    public init( source : Meaning) {
        
        self.source = source
        
        var token = source.next()
        
        while(token != nil) {
            
            stream.addToken(token: token!)
            token = source.next()
        }
        self.main_iter = self.stream.iterator()
    }
    
    open func prepare(content: String) {
        
        if let source = self.source {
            
            source.prepare(content: content)
            stream = TokenStream.init()
            var token = source.next()
            
            while(token != nil) {
                
                stream.addToken(token: token!)
                token = source.next()
            }
            main_iter = stream.iterator()
        }
    }

    open func next()-> Token? {

        return main_iter.read()
    }
}
