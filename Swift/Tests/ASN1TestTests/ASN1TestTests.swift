import XCTest
@testable import ASN1Test
import ASN1Swift

final class SwiftTests: XCTestCase {
    func testDecodeNormal() throws {
        let testBinary = Data([0x30,0x82,0x00,0x16,0x02,0x01,0x07,0x0c,0x09,0x54,0x65,0x73,0x74,0x6f,0x6c,0x6f,0x70,0x65,0x30,0x06,0x02,0x01,0x04,0x02,0x01,0x03])
        
        let asn1Decoder = ASN1Decoder()
        let result = try! asn1Decoder.decode(TestStruct.self, from: testBinary)
        
        XCTAssertEqual(result.number, 7)
        XCTAssertEqual(result.vec, "Testolope")
        XCTAssertEqual(result.tuple.0, 4)
        XCTAssertEqual(result.tuple.1, 3)
    }
    
    func testDecodeUndefinedLength() throws {
        let testBinary = Data([0x30,0x80,0x02,0x01,0x07,0x0c,0x09,0x54,0x65,0x73,0x74,0x6f,0x6c,0x6f,0x70,0x65,0x30,0x06,0x02,0x01,0x04,0x02,0x01,0x03,0x00,0x00])
        
        let asn1Decoder = ASN1Decoder()
        let result = try! asn1Decoder.decode(TestStruct.self, from: testBinary)
        
        XCTAssertEqual(result.number, 7)
        XCTAssertEqual(result.vec, "Testolope")
        XCTAssertEqual(result.tuple.0, 4)
        XCTAssertEqual(result.tuple.1, 3)
    }
}

public struct TestStruct: ASN1Decodable
{
    public var number: Int32
    public var vec: String
    public var tuple: (Int32, Int32)
    
    enum CodingKeys: ASN1CodingKey
    {
        case number
        case vec
        case tuple
        
        var template: ASN1Template
        {
            switch self
            {
            case .number:
                return .universal(ASN1Identifier.Tag.integer)
            case .vec:
                return .universal(ASN1Identifier.Tag.utf8String)
            case .tuple:
                return Tuple.template
            }
        }
    }
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
    
        self.number = try container.decode(Int32.self, forKey: .number)
        self.vec = try container.decode(String.self, forKey: .vec)
        
        let tupleStruct = try container.decode(Tuple.self, forKey: .tuple)
        self.tuple = (tupleStruct.first, tupleStruct.second)
    }
    
    public static var template: ASN1Template
    {
        return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
    }
    
    public struct Tuple: ASN1Decodable
    {
        public var first: Int32
        public var second: Int32
        
        enum CodingKeys: ASN1CodingKey
        {
            case first
            case second
            
            var template: ASN1Template
            {
                switch self
                {
                case .first:
                    return .universal(ASN1Identifier.Tag.integer)
                case .second:
                    return .universal(ASN1Identifier.Tag.integer)
                }
            }
        }
        
        public static var template: ASN1Template
        {
            return ASN1Template.universal(ASN1Identifier.Tag.sequence).constructed()
        }
    }
}
