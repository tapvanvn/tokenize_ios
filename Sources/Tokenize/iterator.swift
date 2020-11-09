
open class TokenStreamIterator {

    var stream : TokenStream? = nil
    var offset : Int = 0
    var level : Int = 0

    public init(stream: TokenStream) {

        self.stream = stream
    }
    //EOS is end of stream
    public var eos : Bool {

        return offset >= ( stream?.length ?? 0 )
    }
    public func seek(to: Int) {
        
        offset = to
    }
    //GetToken read token but not move pointer
    public func get() -> Token? {

        guard let stream = self.stream else {

            return nil
        }
        
        if offset <= (stream.tokens.count - 1) {

            return stream.tokens[offset]
        }
        return nil
    }
    //GetTokenIter get token at (offset + iterator) position
    public func get(by:Int) -> Token? {

        guard let stream = self.stream else {

            return nil
        }
        if offset + by <= stream.tokens.count - 1 {

            let off = offset + by

            return stream.tokens[off]
        }
        return nil
    }
    public func get(at:Int) -> Token? {

        guard let stream = self.stream else {

            return nil
        }
        if at <= stream.tokens.count - 1 {

            return stream.tokens[at]
        }
        return nil
    }
    //ReadToken read token
    public func read() -> Token? {

        guard let stream = self.stream else {

            return nil
        }
        if !eos {

            let off = offset

            offset += 1

            return stream.tokens[off]
        }
        
        return nil
    }

    //ResetToBegin reset to begin
    public func reset() {

        offset = 0
    }
    //ReadFirstTokenType read first token of type
    public func first( type: Int ) -> Token? {

        reset()

        return next(type: type)
    }

    //ReadNextTokenType read from current position to next match of token type
    public func next(type: Int) -> Token? {

        while(!eos) {

            let token = read()

            if token!.type == type {

                return token
            }
        }
        return nil
    }

    //FindPattern search pattern
    public func findPattern(pattern_groups : [PatternGroup], stop_when_found: Bool, is_ignore: (Int)-> Bool ) -> [Mark] {

        var marks : [Mark] = []

        for pattern_group in pattern_groups {

            var token_index = 0

            var pattern_index = 0

            var last_pattern_index = -1

            var mark_ignores : [Int] = []

            var children : [Mark] = []

            var pattern: Pattern!

            var child_mark : Mark!
            
            var child_mark_id = 0

            while(true) {
                
                if pattern_index >= pattern_group.patterns.count {
                    
                    let mark = Mark.init( type: pattern_group.type, begin: self.offset, end: self.offset + token_index, ignores: mark_ignores, children: children )

                    marks.append(mark)

                    if stop_when_found {

                        return marks
                    }
                    break
                }
                
                if pattern_index > last_pattern_index {

                    last_pattern_index = pattern_index

                    pattern = pattern_group.patterns[pattern_index]
                    
                    child_mark_id += 1

                    child_mark = Mark( type: pattern.type, can_nested: pattern.can_nested, is_ignore_in_result: pattern.is_ignore_in_result)
                    
                    child_mark.type = pattern.export_type
                    
                    child_mark.begin = self.offset + token_index
                    
                    children.append( child_mark )

                }
                
                var match: Bool = true

                var move_index : Int = 0

                let next_token = self.get(by: token_index)
                
                if (next_token != nil) {

                    if is_ignore(next_token!.type) {

                        if pattern_group.is_remove_global_ignore || pattern.is_ignore_in_result {

                            mark_ignores.append( self.offset + token_index )
                        }
                        token_index += 1

                        continue
                    }
                } else {

                    break
                }
                
                if pattern.content != "" {

                    if next_token!.content != pattern.content {

                        match = false
                    }
                    if pattern.is_ignore_in_result {

                        mark_ignores.append( self.offset + token_index + move_index )
                    }

                    child_mark.begin = self.offset + token_index

                    move_index = 1

                } else {

                    if next_token!.type != pattern.type {

                        match = false
                    }

                    if pattern.is_ignore_in_result {

                        mark_ignores.append( self.offset + token_index + move_index )
                    }

                    if next_token!.type == pattern.type {

                        child_mark.begin = self.offset + token_index
                    }

                    move_index = 1

                }
                if !match {

                    break
                }

                token_index += move_index

                child_mark.end = self.offset + token_index

                pattern_index += 1
            }
        }
        return marks
    }

    //GetMaskedToken get token from mask
    public func maskedToken( mark: Mark, ignore_offsets :[Int] ) -> Token? {

        var len = mark.end - mark.begin

        var iter = 0

        while (len > 0 && !eos ){

            let nextToken = get(at: mark.begin + iter)

            if !ignore_offsets.contains(mark.begin + iter) {

                return nextToken
            }
            
            len -= 1

            iter += 1
        }
        
        return nil
    }
}
