import XCTest
@testable import Tokenize

final class TokenizeTests: XCTestCase {
    
    func testTokenStream(){
        let content : String = "test=abc test2=bcd"
        
        let stream: TokenStream = TokenStream.init()
        stream.tokenize(content: content)
        
        let iter = stream.iterator()
        
        var result = ""
        
        while( !iter.eos ) {
            
            let token = iter.read()
            
            result += token!.content
        }
        XCTAssertEqual(content, result)
    }
    
    func testTokenStream_Get(){
        
        var content : String = "test=abc test2=bcd"
        
        let stream: TokenStream = TokenStream.init()
        stream.tokenize(content: content)
        
        let iter = stream.iterator()
        
        var result = ""
        
        for i in 0..<content.count {
            
            result += iter.get(by: i)!.content
        }
        XCTAssertEqual(content, result)
        
        iter.reset()
        
        _ = iter.read()
        
        result = ""
        
        for i in 0..<content.count-1 {
            
            result += iter.get(by: i)!.content
        }
        
        content.removeFirst()
        
        XCTAssertEqual(content, result)
    }
    
    func testMeaning_Toknize(){
        
        var token_map = Dictionary<String, RawTokenDefine>()
        token_map["="] = RawTokenDefine(type: 1, separate: true)
        
        let content : String = "test=abc test2=bcd"
        
        let meaning: Meaning = RawMeaning.init(token_map: token_map, separate: false)
        
        meaning.prepare(content: content)
        
        let iter: TokenStreamIterator = meaning.main_iter
        
        var result = ""
        
        while( !iter.eos ) {
            
            let token = iter.read()
            
            result += token!.content
        }
    }
    
    func testMeaning_Next(){
        
        let content : String = "test=abc test2=bcd"
        
        var token_map = Dictionary<String, RawTokenDefine>()
        token_map["="] = RawTokenDefine(type: 1, separate: true)
        token_map[" "] = RawTokenDefine(type: 2, separate: false)
        
        let meaning: Meaning = RawMeaning.init(token_map: token_map, separate: false)
        
        meaning.prepare(content: content)
        
        var result = ""
        
        var token = meaning.next()
        
        while(token != nil ) {
            
            if token!.type != 2 {
                
                result += token!.content
            }
            token = meaning.next()
        }
        
        XCTAssertEqual("test=abctest2=bcd", result)
    }
    
    func testMeaning_Pattern(){
        
        let content : String = "test=abc test2=bcd"
        
        let pattern_groups : [PatternGroup]  = [
            
            PatternGroup.init(type: 100, patterns: [
                
                Pattern.init(type: 0),
                Pattern.init(content: "="),
                Pattern.init(type: 0)
                
            ], is_remove_global_ignore: true)
        ]
        
        var token_map = Dictionary<String, RawTokenDefine>()
        
        token_map["="] = RawTokenDefine(type: 1, separate: true)
        token_map[" "] = RawTokenDefine(type: 2, separate: false)
        
        let meaning: Meaning = RawMeaning.init(token_map: token_map, separate: false)
        
        meaning.prepare(content: content)
        
        let marks = meaning.main_iter.findPattern(pattern_groups: pattern_groups, stop_when_found: true, is_ignore:{_ in return false})
        
        var result = ""
        
        XCTAssertEqual(marks.count, 1)
        
        for mark in marks {

            if let token = meaning.main_iter.maskedToken(mark: mark, ignore_offsets: []) {
                
                result += token.content
            }
            
            XCTAssertEqual(mark.children.count, 3)
            
            for child in mark.children {
                
                if let sub_token = meaning.main_iter.maskedToken(mark: child, ignore_offsets: []) {
                    
                    result += sub_token.content
                }
            }
        }
        
        XCTAssertEqual(result, "testtest=abc")
    }

    func testPatternMeaning_Next(){
        
        let content : String = "test=abc test2=bcd"
        
        let pattern_groups : [PatternGroup]  = [
            
            PatternGroup.init(type: 100, patterns: [
                
                Pattern.init(type: 0),
                Pattern.init(content: "="),
                Pattern.init(type: 0)
                
            ], is_remove_global_ignore: true)
        ]
        
        var token_map = Dictionary<String, RawTokenDefine>()
        
        token_map["="] = RawTokenDefine(type: 1, separate: true)
        token_map[" "] = RawTokenDefine(type: 2, separate: false)
        
        let meaning: Meaning = RawMeaning.init(token_map: token_map, separate: false)
        
        let pattern_meaning = PatternMeaning.init(source:meaning, pattern_groups: pattern_groups, is_ignore_func: {_ in return false})
        
        pattern_meaning.prepare(content: content)
        
        var token = pattern_meaning.next()
        
        var result : [String] = []
        
        while(token != nil) {
            
            result.append(token!.children.content)
            token = pattern_meaning.next()
        }
        
        XCTAssertEqual(result.joined(), "test=abctest2=bcd")
    }
    
    static var allTests = [
        ("testTokenStream", testTokenStream),
        ("testMeaning_Toknize", testMeaning_Toknize),
        //("testExample", testExample),
    ]
}
