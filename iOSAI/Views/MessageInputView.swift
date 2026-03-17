//
//  MessageInputView.swift
//  iOSAI
//
//  Created for iOS 18 Apple Foundation Models integration
//

import SwiftUI

/// View for message input field with send button
struct MessageInputView: View {
    @Binding var text: String
    let isLoading: Bool
    let onSend: () -> Void
    
    @FocusState private var isFocused: Bool
    
    private let maxCharacterCount = 4000
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                // Text input field
                TextField("Message", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...6)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($isFocused)
                    .disabled(isLoading)
                    .onChange(of: text) { _, newValue in
                        // Limit character count
                        if newValue.count > maxCharacterCount {
                            text = String(newValue.prefix(maxCharacterCount))
                        }
                    }
                    .onSubmit {
                        if canSend {
                            onSend()
                        }
                    }
                
                // Send button
                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(canSend ? Color.blue : Color(.systemGray4))
                            .frame(width: 36, height: 36)
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .disabled(!canSend)
                .animation(.easeInOut(duration: 0.2), value: canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Character count indicator (show when approaching limit)
            if text.count > maxCharacterCount - 200 {
                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxCharacterCount)")
                        .font(.caption2)
                        .foregroundStyle(text.count >= maxCharacterCount ? .red : .secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Computed Properties
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        MessageInputView(
            text: .constant("Hello"),
            isLoading: false,
            onSend: {}
        )
    }
}
