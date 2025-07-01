import Testing
import Foundation
import Swallow
@testable import PropertyList

public struct PropertyListHandleTests {
    @Test(arguments: ["bplist.plist"])
    func test_isBplist(filename: String) throws {
        let url = try #require(testPropertyListURL(for: filename))
        let handle = try MapHandle(url: url)
        let isBplist = PropertyList.BinaryPropertyListHandle.isBplist(contents: handle.contents, mapSize: handle.mapSize)
        #expect(isBplist)
    }
    
    @Test(arguments: ["xml.plist"])
    func test_isXML(filename: String) throws {
        let url = try #require(testPropertyListURL(for: filename))
        let handle = try MapHandle(url: url)
        let isXML = PropertyList.XMLPropertyListHandle.isXML(contents: handle.contents, mapSize: handle.mapSize)
        #expect(isXML)
    }
    
    @Test(arguments: ["openStep.plist"])
    func test_isOpenStep(filename: String) throws {
        let url = try #require(testPropertyListURL(for: filename))
        let handle = try MapHandle(url: url)
        let isOpenStep = PropertyList.OpenStepPropertyListHandle.isOpenStep(contents: handle.contents, mapSize: handle.mapSize)
        #expect(isOpenStep)
    }
}
