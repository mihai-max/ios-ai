//
//  TypingIndicatorView.swift
//  iOSAI
//
//  Created for iOS 18 Apple Foundation Models integration
//

import SwiftUI

/// Animated typing indicator view
struct TypingIndicatorView: View {
    @State private var animationPhase = 0
    
    private let dotCount = 3
    private let animationDuration = 0.6
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // AI avatar placeholder
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            
            // Typing dots
            HStack(spacing: 4) {
                ForEach(0..<dotCount, id: \.self) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(scaleForDot(at: index))
                        .opacity(opacityForDot(at: index))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Animation Methods
    
    private func startAnimation() {
        withAnimation(
            .easeInOut(duration: animationDuration)
            .repeatForever(autoreverses: true)
        ) {
            animationPhase = (animationPhase + 1) % dotCount
        }
    }
    
    private func scaleForDot(at index: Int) -> CGFloat {
        let phase = (animationPhase + index) % dotCount
        switch phase {
        case 0:
            return 1.0
        case 1:
            return 1.3
        case 2:
            return 0.8
        default:
            return 1.0
        }
    }
    
    private func opacityForDot(at index: Int) -> Double {
        let phase = (animationPhase + index) % dotCount
        switch phase {
        case 0:
            return 0.5
        case 1:
            return 1.0
        case 2:
            return 0.3
        default:
            return 0.5
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        TypingIndicatorView()
        Spacer()
    }
    .padding()
}
