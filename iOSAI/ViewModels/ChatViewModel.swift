//
//  ChatViewModel.swift
//  iOSAI
//
//  Created for iOS 18 Apple Foundation Models integration
//

import Foundation
import FoundationModels
import SwiftUI

/// ViewModel managing chat interactions with Apple Foundation Models
@Observable
@MainActor
final class ChatViewModel {
    // MARK: - Properties
    
    /// Array of chat messages
    var messages: [ChatMessage] = []
    
    /// Current input text
    var inputText: String = ""
    
    /// Loading state indicator
    var isLoading: Bool = false
    
    /// Error message to display
    var errorMessage: String?
    
    /// Whether to show error alert
    var showError: Bool = false
    
    /// Language model session for Foundation Models
    private var session: LanguageModelSession?
    
    /// Whether Apple Intelligence is available on this device
    var isAppleIntelligenceAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }
    
    /// Apple Intelligence availability status message
    var availabilityStatus: String {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            return "Apple Intelligence is available"
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                return "Apple Intelligence is not enabled. Please enable it in Settings."
            case .deviceNotEligible:
                return "This device does not support Apple Intelligence."
            case .modelNotReady:
                return "Apple Intelligence model is downloading. Please wait."
            @unknown default:
                return "Apple Intelligence is unavailable."
            }
        @unknown default:
            return "Unknown availability status"
        }
    }
    
    // MARK: - Initialization
    
    init() {
        setupSession()
    }
    
    // MARK: - Private Methods
    
    /// Sets up the language model session
    private func setupSession() {
        let model = SystemLanguageModel.default
        
        guard model.isAvailable else {
            errorMessage = availabilityStatus
            showError = true
            return
        }
        
        // Create a new session with system instructions
        session = LanguageModelSession(model: model) {
            """
            You are a helpful AI assistant powered by Apple Intelligence. \
            Provide clear, concise, and helpful responses. \
            You can use markdown formatting in your responses.
            """
        }
    }
    
    /// Sends a message to the Foundation Model
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage.userMessage(trimmedText)
        messages.append(userMessage)
        inputText = ""
        
        // Start loading
        isLoading = true
        
        Task {
            await generateResponse(for: trimmedText)
        }
    }
    
    /// Generates a response from the Foundation Model
    private func generateResponse(for prompt: String) async {
        guard let session = session else {
            await handleError("Language model session not available")
            return
        }
        
        do {
            // Create a placeholder AI message for streaming
            var aiMessage = ChatMessage.aiMessage("")
            messages.append(aiMessage)
            
            // Stream the response
            let stream = session.streamResponse(to: prompt)

            for try await partialResponse in stream {
                let currentContent = partialResponse.text

                // Update the last message with the latest partial content
                if let lastIndex = messages.indices.last {
                    messages[lastIndex] = ChatMessage(
                        id: aiMessage.id,
                        content: currentContent,
                        isUser: false,
                        timestamp: aiMessage.timestamp,
                        status: .sent
                    )
                }
            }
            
            // Mark user message as sent
            if let userIndex = messages.firstIndex(where: { $0.id == messages[messages.count - 2].id }) {
                messages[userIndex].status = .sent
            }
            
        } catch {
            await handleError(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    /// Handles errors
    private func handleError(_ message: String) async {
        errorMessage = message
        showError = true
        
        // Add error message to chat
        let errorMsg = ChatMessage.errorMessage("Error: \(message)")
        messages.append(errorMsg)
        
        isLoading = false
    }
    
    /// Clears the chat history
    func clearChat() {
        messages.removeAll()
        setupSession() // Reset session for fresh conversation
    }
    
    /// Retries the last failed message
    func retryLastMessage() {
        // Find the last user message
        guard let lastUserMessage = messages.last(where: { $0.isUser }) else { return }
        
        // Remove the last AI/error message if present
        if let lastMessage = messages.last, !lastMessage.isUser {
            messages.removeLast()
        }
        
        // Update user message status
        if let index = messages.firstIndex(where: { $0.id == lastUserMessage.id }) {
            messages[index].status = .sending
        }
        
        isLoading = true
        Task {
            await generateResponse(for: lastUserMessage.content)
        }
    }
    
    /// Copies message content to clipboard
    func copyMessage(_ message: ChatMessage) {
        #if os(iOS)
        UIPasteboard.general.string = message.content
        #elseif os(macOS)
        NSPasteboard.general.setString(message.content, forType: .string)
        #endif
    }
}
