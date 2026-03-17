//
//  ContentView.swift
//  iOSAI
//
//  Created for iOS 18 Apple Foundation Models integration
//

import SwiftUI

/// Main chat interface view
struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    @State private var showClearConfirmation = false
    @State private var scrollToBottom = false
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat messages area
                chatMessagesArea
                
                // Message input
                MessageInputView(
                    text: $viewModel.inputText,
                    isLoading: viewModel.isLoading,
                    onSend: viewModel.sendMessage
                )
            }
            .navigationTitle("Apple Intelligence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Label("Clear Chat", systemImage: "trash")
                        }
                        
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("Share Conversation", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    // Status indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(viewModel.isAppleIntelligenceAvailable ? .green : (viewModel.isSimulationMode ? .orange : .red))
                            .frame(width: 8, height: 8)
                        
                        Text(viewModel.isAppleIntelligenceAvailable ? "Ready" : (viewModel.isSimulationMode ? "Simulation" : "Unavailable"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Clear Chat", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    viewModel.clearChat()
                }
            } message: {
                Text("Are you sure you want to clear all messages?")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
                Button("Retry") {
                    viewModel.retryLastMessage()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: [generateShareableText()])
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var chatMessagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Simulation mode banner
                    if viewModel.isSimulationMode {
                        simulationModeBanner
                    }
                    
                    // Welcome message when empty
                    if viewModel.messages.isEmpty {
                        welcomeView
                    }
                    
                    // Chat messages
                    ForEach(viewModel.messages) { message in
                        ChatBubbleView(message: message)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    
                    // Typing indicator
                    if viewModel.isLoading && viewModel.messages.last?.isUser == true {
                        TypingIndicatorView()
                            .id("typingIndicator")
                            .transition(.opacity)
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToLatestMessage(proxy: proxy)
            }
            .onChange(of: viewModel.isLoading) { _, isLoading in
                if isLoading {
                    scrollToLatestMessage(proxy: proxy)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)
            
            // App icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 8) {
                Text("Apple Intelligence")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Powered by on-device Foundation Models")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Feature highlights
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "lock.shield", text: "Private & secure - runs on-device")
                FeatureRow(icon: "bolt", text: "Fast responses with no internet required")
                FeatureRow(icon: "text.quote", text: "Supports markdown formatting")
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private var simulationModeBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.caption)
            
            Text("Running in simulation mode. iOS 18+ required for Apple Intelligence.")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Private Methods
    
    private func generateShareableText() -> String {
        var text = "Apple Intelligence Chat Conversation\n"
        text += "Generated on \(Date().formatted(date: .long, time: .shortened))\n\n"
        
        for message in viewModel.messages {
            let sender = message.isUser ? "You" : "Apple Intelligence"
            text += "\(sender): \(message.content)\n\n"
        }
        
        return text
    }
    
    private func scrollToLatestMessage(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            if viewModel.isLoading {
                proxy.scrollTo("typingIndicator", anchor: .bottom)
            } else if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    ContentView()
}
