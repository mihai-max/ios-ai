//
//  ChatViewModel.swift
//  iOSAI
//
//  Created for iOS 18 Apple Foundation Models integration
//

import Foundation
import SwiftUI

// Conditionally import FoundationModels only on iOS 18+
#if canImport(FoundationModels)
import FoundationModels
#endif

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
    
    /// Language model session for Foundation Models (iOS 18+ only)
    #if canImport(FoundationModels)
    private var session: LanguageModelSession?
    #endif
    
    /// Whether running in simulation mode (iOS 17 or when FoundationModels unavailable)
    var isSimulationMode: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 18.0, *) {
            return !SystemLanguageModel.default.isAvailable
        }
        #endif
        return true
    }
    
    /// Whether Apple Intelligence is available on this device
    var isAppleIntelligenceAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 18.0, *) {
            return SystemLanguageModel.default.isAvailable
        }
        #endif
        return false
    }
    
    /// Apple Intelligence availability status message
    var availabilityStatus: String {
        #if canImport(FoundationModels)
        if #available(iOS 18.0, *) {
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
        #endif
        return "Running in simulation mode (iOS 18+ required for Apple Intelligence)"
    }
    
    // MARK: - Initialization
    
    init() {
        setupSession()
    }
    
    // MARK: - Private Methods
    
    /// Sets up the language model session
    private func setupSession() {
        #if canImport(FoundationModels)
        if #available(iOS 18.0, *) {
            let model = SystemLanguageModel.default
            
            guard model.isAvailable else {
                errorMessage = availabilityStatus
                showError = true
                return
            }
            
            // Create a new session with optional instructions
            session = LanguageModelSession(
                model: model,
                instructions: {
                    """
                    You are a helpful AI assistant powered by Apple Intelligence. \
                    Provide clear, concise, and helpful responses. \
                    You can use markdown formatting in your responses.
                    """
                }
            )
            return
        }
        #endif
        
        // Simulation mode for iOS 17 or when FoundationModels unavailable
        print("Running in simulation mode - FoundationModels not available")
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
        #if canImport(FoundationModels)
        if #available(iOS 18.0, *), let session = session {
            do {
                // Create a placeholder AI message for streaming
                let aiMessage = ChatMessage.aiMessage("")
                messages.append(aiMessage)
                
                // Stream the response
                let stream = session.streamResponse(to: prompt)
                
                var fullResponse = ""
                for try await chunk in stream {
                    fullResponse += chunk
                    
                    // Update the last message with streaming content
                    if let lastIndex = messages.indices.last {
                        messages[lastIndex] = ChatMessage(
                            id: aiMessage.id,
                            content: fullResponse,
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
            return
        }
        #endif
        
        // Simulation mode - generate mock responses
        await simulateResponse(for: prompt)
    }
    
    /// Simulates AI responses for iOS 17 or when FoundationModels unavailable
    private func simulateResponse(for prompt: String) async {
        // Create a placeholder AI message
        let aiMessage = ChatMessage.aiMessage("")
        messages.append(aiMessage)
        
        // Simulate typing delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Generate a simulated response based on the prompt
        let simulatedResponse = generateSimulatedResponse(for: prompt)
        
        // Simulate streaming by adding text in chunks
        var fullResponse = ""
        let words = simulatedResponse.split(separator: " ")
        
        for (index, word) in words.enumerated() {
            fullResponse += (index == 0 ? "" : " ") + word
            
            if let lastIndex = messages.indices.last {
                messages[lastIndex] = ChatMessage(
                    id: aiMessage.id,
                    content: fullResponse,
                    isUser: false,
                    timestamp: aiMessage.timestamp,
                    status: .sent
                )
            }
            
            // Small delay between words to simulate streaming
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        }
        
        // Mark user message as sent
        if let userIndex = messages.firstIndex(where: { $0.id == messages[messages.count - 2].id }) {
            messages[userIndex].status = .sent
        }
        
        isLoading = false
    }
    
    /// Generates a simulated response based on the prompt
    private func generateSimulatedResponse(for prompt: String) -> String {
        let lowercasedPrompt = prompt.lowercased()
        
        if lowercasedPrompt.contains("hello") || lowercasedPrompt.contains("hi") {
            return "Hello! I'm your AI assistant running in simulation mode. On iOS 18+ with Apple Intelligence enabled, I would use on-device Foundation Models for real AI responses. How can I help you today?"
        } else if lowercasedPrompt.contains("help") {
            return "I'd be happy to help! In simulation mode, I can demonstrate the chat interface. For full AI capabilities, you'll need:\n\n- iOS 18 or later\n- iPhone 15 Pro or later (A17 Pro chip)\n- Apple Intelligence enabled in Settings\n\nWhat would you like to know?"
        } else if lowercasedPrompt.contains("feature") || lowercasedPrompt.contains("what can you do") {
            return "This app demonstrates a chat interface for Apple Intelligence. Key features include:\n\n- **Streaming responses** - Text appears as it's generated\n- **Markdown support** - Rich text formatting\n- **On-device processing** - Private and secure\n- **Modern SwiftUI interface** - Clean and intuitive\n\nNote: This is running in simulation mode."
        } else if lowercasedPrompt.contains("thank") {
            return "You're welcome! Feel free to ask if you have any other questions."
        } else {
            return "I received your message: \"\(prompt)\"\n\nThis is a simulated response. On iOS 18+ with Apple Intelligence, I would use the Foundation Models framework to generate real AI responses powered by on-device language models.\n\nIs there anything specific you'd like to know about this app?"
        }
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
    
    /// Copies message content to clipboard
    func copyMessage(_ message: ChatMessage) {
        #if os(iOS)
        UIPasteboard.general.string = message.content
        #elseif os(macOS)
        NSPasteboard.general.setString(message.content, forType: .string)
        #endif
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
    
}
