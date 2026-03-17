//
//  ChatMessage.swift
//  iOSAI
//
//  Created for iOS 18 Apple Foundation Models integration
//

import Foundation

/// Represents the status of a chat message
enum MessageStatus: String, Codable, CaseIterable {
    case sending
    case sent
    case error
}

/// Represents a single chat message in the conversation
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    var status: MessageStatus
    
    init(
        id: UUID = UUID(),
        content: String,
        isUser: Bool,
        timestamp: Date = Date(),
        status: MessageStatus = .sent
    ) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.status = status
    }
    
    /// Creates a user message
    static func userMessage(_ content: String) -> ChatMessage {
        ChatMessage(content: content, isUser: true, status: .sending)
    }
    
    /// Creates an AI message
    static func aiMessage(_ content: String) -> ChatMessage {
        ChatMessage(content: content, isUser: false, status: .sent)
    }
    
    /// Creates an error message
    static func errorMessage(_ content: String) -> ChatMessage {
        ChatMessage(content: content, isUser: false, status: .error)
    }
}

// MARK: - Equatable
extension ChatMessage: Equatable {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension ChatMessage: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
