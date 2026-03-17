//
//  ChatViewModelTests.swift
//  iOSAITests
//
//  Created for iOS 18 Apple Foundation Models integration
//

import XCTest
@testable import iOSAI

@MainActor
final class ChatViewModelTests: XCTestCase {
    
    var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ChatViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.messages.isEmpty)
        XCTAssertEqual(viewModel.inputText, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showError)
    }
    
    // MARK: - Message Model Tests
    
    func testUserMessageCreation() {
        let message = ChatMessage.userMessage("Hello")
        
        XCTAssertEqual(message.content, "Hello")
        XCTAssertTrue(message.isUser)
        XCTAssertEqual(message.status, .sending)
    }
    
    func testAIMessageCreation() {
        let message = ChatMessage.aiMessage("Hi there!")
        
        XCTAssertEqual(message.content, "Hi there!")
        XCTAssertFalse(message.isUser)
        XCTAssertEqual(message.status, .sent)
    }
    
    func testErrorMessageCreation() {
        let message = ChatMessage.errorMessage("Error occurred")
        
        XCTAssertEqual(message.content, "Error occurred")
        XCTAssertFalse(message.isUser)
        XCTAssertEqual(message.status, .error)
    }
    
    func testMessageEquality() {
        let id = UUID()
        let message1 = ChatMessage(id: id, content: "Test", isUser: true)
        let message2 = ChatMessage(id: id, content: "Different", isUser: false)
        
        // Messages with same ID should be equal
        XCTAssertEqual(message1, message2)
    }
    
    func testMessageHashable() {
        let message1 = ChatMessage.userMessage("Test 1")
        let message2 = ChatMessage.userMessage("Test 2")
        
        var set = Set<ChatMessage>()
        set.insert(message1)
        set.insert(message2)
        
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Message Status Tests
    
    func testMessageStatusCases() {
        let statuses: [MessageStatus] = [.sending, .sent, .error]
        XCTAssertEqual(statuses.count, 3)
    }
    
    func testMessageStatusRawValues() {
        XCTAssertEqual(MessageStatus.sending.rawValue, "sending")
        XCTAssertEqual(MessageStatus.sent.rawValue, "sent")
        XCTAssertEqual(MessageStatus.error.rawValue, "error")
    }
    
    // MARK: - Clear Chat Tests
    
    func testClearChat() {
        // Add some messages
        viewModel.messages = [
            ChatMessage.userMessage("Hello"),
            ChatMessage.aiMessage("Hi!")
        ]
        
        viewModel.clearChat()
        
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    // MARK: - Input Validation Tests
    
    func testEmptyInputDoesNotSend() {
        viewModel.inputText = ""
        viewModel.sendMessage()
        
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testWhitespaceOnlyInputDoesNotSend() {
        viewModel.inputText = "   \n\t  "
        viewModel.sendMessage()
        
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    // MARK: - Codable Tests
    
    func testChatMessageCodable() throws {
        let message = ChatMessage(
            content: "Test message",
            isUser: true,
            status: .sent
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ChatMessage.self, from: data)
        
        XCTAssertEqual(decoded.id, message.id)
        XCTAssertEqual(decoded.content, message.content)
        XCTAssertEqual(decoded.isUser, message.isUser)
        XCTAssertEqual(decoded.status, message.status)
    }
    
    // MARK: - Performance Tests
    
    func testMessageCreationPerformance() {
        measure {
            for i in 0..<1000 {
                _ = ChatMessage.userMessage("Message \(i)")
            }
        }
    }
}
