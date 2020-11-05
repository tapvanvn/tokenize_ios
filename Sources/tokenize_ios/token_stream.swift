class TokenStream {

    var tokens : [Token] = []

    //Length get len of stream
    var length: Int {

        return tokens.count
    }

    var content : String {

        let iter = iterator()

        var content = ""

        while (!iter.eos) {

            let token = iter.read()

            content += token!.content
        }

        return content
    }

    func iterator() -> TokenStreamIterator {

        return TokenStreamIterator.init(stream: self)
    }

    func addToken(token: Token) {

        tokens.append(token)
    }

    //Tokenize tokenize a string
    func tokenize(content: String) {

        for character in content {

            let token = Token.init(content:String(character))

            addToken(token: token)
        }
    }

    func tokenize(content:String, type:Int) {

        for character in content {

            let token = Token.init(content:String(character), type: type)

            addToken(token: token)
        }
    }
    
    /*

    //Debug print debug tree
    func (stream *TokenStream) Debug(level int, fnName func(int) string) {

        for _, token := range stream.Tokens {

            trimContent := strings.Trim(token.Content, " \n\r")

            if len(trimContent) > 0 || token.Children.Length() > 0 {

                for i := 0; i <= level; i++ {

                    if i == 0 {

                        fmt.Printf("|%s ", ColorType(token.Type))

                    } else {

                        fmt.Print("| ")
                    }
                }

                if fnName != nil {

                    if len(trimContent) > 0 {

                        fmt.Printf("%s", ColorContent(token.Content))

                    } else {

                        fmt.Print("")
                    }
                    fmt.Printf("-%s\n", ColorName(fnName(token.Type)))

                } else {

                    if len(trimContent) > 0 {

                        fmt.Println(token.Content)

                    } else {

                        fmt.Println("")
                    }
                }

            }
            token.Children.Debug(level+1, fnName)
        }
    }

    //DebugMark debug mark
    func (iterator *TokenStreamIterator) DebugMark(level int, mark *Mark, ignores *[]int, fnName func(int) string) {

        length := mark.End - mark.Begin

        iter := 0

        for {
            if length <= 0 || iterator.EOS() {
                break
            }

            token := iterator.GetTokenAt(mark.Begin + iter)
            fmt.Printf("%s", ColorOffset(mark.Begin+iter))
            if token != nil {

                for i := 0; i <= level; i++ {

                    if i == 0 {

                        fmt.Printf("|%s ", ColorType(token.Type))

                    } else {

                        fmt.Print("| ")
                    }
                }

                if !isIgnoreInMark(mark.Begin+iter, ignores) {

                    trimContent := strings.Trim(token.Content, " \n\r")

                    if len(trimContent) > 0 {

                        fmt.Printf("%s", ColorContent(token.Content))

                    } else {

                        fmt.Print("")
                    }

                    fmt.Printf("-%s\n", ColorName(fnName(token.Type)))

                } else {

                    fmt.Printf("%s", ColorIgnore())
                }

            } else {

                fmt.Printf("%s", "nil")
            }

            fmt.Println("")

            length--

            iter++
        }
    }

    

    //GetTokenIter get token at (offset + iterator) position
    func (iterator *TokenStreamIterator) GetTokenIter(iter int) *BaseToken {

        if iterator.Offset+iter <= len(iterator.Stream.Tokens)-1 {

            off := iterator.Offset + iter

            return &iterator.Stream.Tokens[off]
        }
        return nil
    }

    

    

    

    */
}

class TokenStreamIterator {

    var stream : TokenStream? = nil
    var offset : Int = 0
    var level : Int = 0

    init(stream: TokenStream) {

        self.stream = stream
    }
    //EOS is end of stream
    var eos : Bool {

        return offset >= ( stream?.length ?? 0 )
    }
    //GetToken read token but not move pointer
    func get() -> Token? {

        guard let stream = self.stream else {

            return nil
        }
        
        if offset <= (stream.tokens.count - 1) {

            return stream.tokens[offset]
        }
        return nil
    }
    //GetTokenIter get token at (offset + iterator) position
    func get(by:Int) -> Token? {

        guard let stream = self.stream else {

            return nil
        }
        if offset + by <= stream.tokens.count - 1 {

            let off = offset + by

            return stream.tokens[off]
        }
        return nil
    }
    //ReadToken read token
    func read() -> Token? {

        guard let stream = self.stream else {

            return nil
        }
        if offset <= stream.tokens.count - 1 {

            let off = offset

            offset += 1

            return stream.tokens[off]
        }
        return nil
    }

    //ResetToBegin reset to begin
    func reset() {

        offset = 0
    }
    //ReadFirstTokenType read first token of type
    func first( type: Int ) -> Token? {

        reset()

        return next(type: type)
    }

    //ReadNextTokenType read from current position to next match of token type
    func next(type: Int) -> Token? {

        while(!eos) {

            let token = read()

            if token!.type == type {

                return token
            }
        }
        return nil
    }

    //FindPattern search pattern
    func findPattern(pattern_groups : [PatternGroup], stopWhenFound: Bool, phraseBreak : Int, isIgnore: (Int)-> Bool, fnName: (Int)->String ) -> [Mark] {

        var marks : [Mark] = []

        //log := &Log{}

        for pattern_group in pattern_groups {

            var iter = 0

            var iterToken = 0

            var traceIterToken = -1

            let patternTokenNum = pattern_group.patterns.count

            var ignores : [Int] = []

            var children : [Mark] = []

            var patternToken: Pattern!

            var childMark : Mark? = nil

            while(true) {

                if iterToken >= patternTokenNum {

                    let mark = Mark( type: pattern_group.type, 
                        begin: self.offset, 
                        end: self.offset + iter, 
                        ignores: ignores, 
                        can_nested: false,
                        children: children, 
                        is_ignore_in_result: false, 
                        is_token_stream: false 
                        )

                    marks.append(mark)

                    //log.Append(fmt.Sprintf("=>[%s] \n", ColorSuccess()))

                    if stopWhenFound {

                        return marks
                    }
                    break
                }
                if iterToken > traceIterToken {

                    traceIterToken = iterToken

                    patternToken = pattern_group.patterns[iterToken]

                    childMark = Mark(
                        type:             patternToken.type,
                        begin: 0,
                        end: 0,
                        ignores: [],
                        can_nested:        patternToken.can_nested,
                        children: [],
                        is_ignore_in_result: patternToken.is_ignore_in_result,
                        is_token_stream:    patternToken.is_phrase_until
                    )
                    if patternToken.export_type > 0 {

                        childMark!.type = patternToken.export_type
                    }

                    children.append(childMark!)

                    childMark!.begin = self.offset + iter

                    //log.Append(fmt.Sprintf("\n\t[%s %s] %s %t", ColorType(patternToken.Type), ColorName(fnName(patternToken.Type)), ColorContent(patternToken.Content), patternToken.IsPhraseUntil))
                }
                var match: Bool = true

                var moveIter : Int = 0

                let nextToken = self.get(by: iter)

                if nextToken == nil {

                    break
                }

                if nextToken!.type == phraseBreak || isIgnore(nextToken!.type) {

                    if pattern_group.is_remove_global_ignore || patternToken.is_ignore_in_result {

                        ignores.append( self.offset + iter )
                    }
                    iter += 1

                    //log.Append(fmt.Sprintf("\n"))

                    continue
                }
                if patternToken.content != "" {

                    let currToken = self.get(by: iter)

                    if currToken == nil || currToken!.content != patternToken.content {

                        match = false

                        //log.Append(fmt.Sprintf("=>[%s %s %s]", ColorFail(), ColorType(currToken.Type), ColorContent(currToken.Content)))
                    }
                    if patternToken.is_ignore_in_result {

                        ignores.append( self.offset + iter + moveIter )
                    }

                    childMark!.begin = self.offset + iter

                    moveIter = 1

                } else if patternToken.type > 0 {

                    let currToken = self.get(by: iter)

                    if currToken == nil || (currToken!.type != phraseBreak && currToken!.type != patternToken.type) {

                        match = false

                        //log.Append(fmt.Sprintf("=>[%s %s %s]", ColorFail(), ColorType(currToken.Type), ColorContent(currToken.Content)))
                    }

                    if patternToken.is_ignore_in_result {

                        ignores.append( self.offset + iter + moveIter )
                    }

                    if currToken!.type == patternToken.type {

                        childMark!.begin = self.offset + iter
                    }

                    moveIter = 1

                } else if patternToken.is_phrase_until {

                    var isWordFound = false

                    while(true) {

                        let currToken = self.get(by: iter + moveIter)

                        if currToken == nil {

                            match = false

                            //log.Append(fmt.Sprintf("=>[%s]", ColorFail()))

                            break
                        }

                        if isIgnore(currToken!.type) {

                            if pattern_group.is_remove_global_ignore || patternToken.is_ignore_in_result {

                                ignores.append( self.offset + iter + moveIter)
                            }

                            moveIter += 1

                            continue
                        }
                        if currToken!.type == phraseBreak && isWordFound {

                            if pattern_group.is_remove_global_ignore || patternToken.is_ignore_in_result {

                                ignores.append( self.offset + iter + moveIter)
                            }
                            moveIter += 1

                            break

                        } else if currToken!.type != phraseBreak && currToken!.content.count > 0 {

                            isWordFound = true
                        }

                        if patternToken.is_ignore_in_result {

                            ignores.append( self.offset + iter + moveIter)
                        }

                        moveIter += 1
                    }
                }
                if !match {

                    break
                }

                iter += moveIter

                childMark!.end = self.offset + iter

                iterToken += 1

                //log.Append(fmt.Sprintf("\n"))
            }
        }
        return marks
    }

    //GetMaskedToken get token from mask
    func maskedToken( mark: Mark, ignore_offsets :[Int] ) -> Token? {

        var len = mark.end - mark.begin

        var iter = 0

        if mark.is_token_stream {

            let token = Token.init ( type: mark.type )

            while ( len > 0 &&  !eos ) {

                let nextToken = get( by: mark.begin + iter )

                if !ignore_offsets.contains (mark.begin + iter) {

                    token.children.addToken(token: nextToken!)

                }
                len -= 1

                iter += 1
            }

            return token

        } else {

            while (len > 0 && !eos ){

                let nextToken = get(by: mark.begin + iter)

                if !ignore_offsets.contains(mark.begin + iter) {

                    return nextToken
                }
                len -= 1

                iter += 1
            }
        }
        return nil
    }
}