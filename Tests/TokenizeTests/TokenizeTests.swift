import XCTest
@testable import Tokenize

var pattern_groups : [PatternGroup]  = [
    
    PatternGroup.init(type: 100, patterns: [
        
        Pattern.init(type: Meaning.BasicTokenType.word.rawValue),
        Pattern.init(content: "="),
        Pattern.init(type: Meaning.BasicTokenType.word.rawValue)
        
    ], is_remove_global_ignore: true)
]

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
        
        let content : String = "test=abc test2=bcd"
        
        let meaning: Meaning = Meaning.init(content: content, operators: "=", spaces: " ")
        
        let iter: TokenStreamIterator = meaning.main_iter
        
        var result = ""
        
        while( !iter.eos ) {
            
            let token = iter.read()
            
            result += token!.content
        }
    }
    
    func testMeaning_Next(){
        
        let content : String = "test=abc test2=bcd"
        
        let meaning: Meaning = Meaning.init(content: content, operators: "=", spaces: " ")
        
        var result = ""
        
        var token = meaning.next()
        
        while(token != nil ) {
            
            result += token!.content
            
            token = meaning.next()
        }
        
        XCTAssertEqual("test=abctest2=bcd", result)
    }
    
    func testMeaning_Pattern(){
        
        let content : String = "test=abc test2=bcd"
        
        let pattern_groups : [PatternGroup]  = [
            
            PatternGroup.init(type: 100, patterns: [
                
                Pattern.init(type: Meaning.BasicTokenType.word.rawValue),
                Pattern.init(content: "="),
                Pattern.init(type: Meaning.BasicTokenType.word.rawValue)
                
            ], is_remove_global_ignore: true)
        ]
        
        let meaning: Meaning = Meaning.init(content: content, operators: "=", spaces: " ")
        
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
                
                Pattern.init(type: Meaning.BasicTokenType.word.rawValue),
                Pattern.init(content: "="),
                Pattern.init(type: Meaning.BasicTokenType.word.rawValue)
                
            ], is_remove_global_ignore: true)
        ]
        
        let meaning = PatternMeaning.init(content: content, operators: "=", spaces: " ", pattern_groups: pattern_groups, is_ignore_func: {_ in return false})
        
        var token = meaning.next()
        
        var result : [String] = []
        
        while(token != nil) {
            
            result.append(token!.children.content)
            token = meaning.next()
        }
        
        XCTAssertEqual(result.joined(), "test=abctest2=bcd")
    }
    
    static var allTests = [
        ("testTokenStream", testTokenStream),
        ("testMeaning_Toknize", testMeaning_Toknize),
        //("testExample", testExample),
    ]
}
