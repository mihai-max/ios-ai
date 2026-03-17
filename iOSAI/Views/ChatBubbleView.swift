//
//  ChatBubbleView.swift
//  iOSAI
//
//  Created for iOS 18 Apple Foundation Models integration
//

import SwiftUI

/// View for displaying a single chat message bubble
struct ChatBubbleView: View {
    let message: ChatMessage
    
    @State private var showCopyConfirmation = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message content
                messageContent
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(backgroundForMessage)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                
                // Timestamp and status
                HStack(spacing: 4) {
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    if message.status == .sending {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else if message.status == .error {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .contextMenu {
            Button {
                copyToClipboard()
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            if message.status == .error {
                Button {
                    // Retry action would be handled by parent
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
            }
        }
        .overlay {
            if showCopyConfirmation {
                Text("Copied!")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var messageContent: some View {
        if message.isUser {
            Text(message.content)
                .foregroundStyle(.white)
                .textSelection(.enabled)
        } else {
            // Render markdown for AI messages
            if let attributedString = try? AttributedString(markdown: message.content) {
                Text(attributedString)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            } else {
                Text(message.content)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }
        }
    }
    
    private var backgroundForMessage: some ShapeStyle {
        if message.isUser {
            return LinearGradient(
                colors: [.blue, .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if message.status == .error {
            return Color.red.opacity(0.1)
        } else {
            return Color(.systemGray6)
        }
    }
    
    // MARK: - Private Methods
    
    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = message.content
        #elseif os(macOS)
        NSPasteboard.general.setString(message.content, forType: .string)
        #endif
        
        withAnimation {
            showCopyConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopyConfirmation = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ChatBubbleView(message: .userMessage("Hello, how are you?"))
        ChatBubbleView(message: .aiMessage("I'm doing great! How can I help you today?"))
        ChatBubbleView(message: .errorMessage("Something went wrong"))
    }
    .padding()
}
