# iOS 18 App for Apple Foundation Models - Implementation Plan

## Overview
Create a SwiftUI-based iOS 18 app that allows users to have conversations with Apple's on-device Foundation Models (Apple Intelligence).

## Project Structure
```
ios-ai/
├── iOSAI/
│   ├── iOSAIApp.swift              # Main app entry point
│   ├── ContentView.swift           # Main chat interface
│   ├── Models/
│   │   └── ChatMessage.swift       # Message data model
│   ├── ViewModels/
│   │   └── ChatViewModel.swift     # Chat logic and Foundation Models integration
│   ├── Views/
│   │   ├── ChatBubbleView.swift    # Individual message bubble
│   │   ├── MessageInputView.swift  # Text input field
│   │   └── TypingIndicatorView.swift # Loading/typing indicator
│   └── Resources/
│       └── Assets.xcassets/        # App assets
├── iOSAITests/
│   └── ChatViewModelTests.swift    # Unit tests
└── README.md                       # Project documentation
```

## Implementation Details

### 1. App Entry Point (iOSAIApp.swift)
- Configure app with SwiftUI App lifecycle
- Set minimum deployment target to iOS 18.0
- Enable Apple Intelligence entitlement

### 2. Data Models (ChatMessage.swift)
- Define `ChatMessage` struct with:
  - `id`: UUID
  - `content`: String
  - `isUser`: Bool (true for user messages, false for AI)
  - `timestamp`: Date
  - `status`: MessageStatus enum (.sending, .sent, .error)

### 3. ViewModel (ChatViewModel.swift)
- Use `@Observable` macro for state management
- Integrate with Apple Foundation Models:
  - Import `FoundationModels` framework
  - Create `LanguageModelSession` instance
  - Handle streaming responses
- Properties:
  - `messages`: Array of ChatMessage
  - `inputText`: Current input
  - `isLoading`: Loading state
  - `errorMessage`: Error handling
- Methods:
  - `sendMessage()`: Send user message and get AI response
  - `clearChat()`: Reset conversation
  - `retryLastMessage()`: Retry failed messages

### 4. Views

#### ContentView.swift
- NavigationStack with chat title
- ScrollView for message list
- MessageInputView at bottom
- Error alerts

#### ChatBubbleView.swift
- Different styling for user vs AI messages
- Animated appearance
- Markdown rendering for AI responses
- Copy button for AI messages

#### MessageInputView.swift
- TextField with placeholder
- Send button (disabled when loading or empty)
- Character count indicator

#### TypingIndicatorView.swift
- Animated dots indicating AI is thinking

### 5. Configuration
- Info.plist with required permissions
- Entitlements file for Apple Intelligence
- Privacy manifest

### 6. Testing
- Unit tests for ChatViewModel
- Mock LanguageModelSession for testing
- Test message flow and error handling

## Key Features
1. Real-time streaming responses from Foundation Models
2. Conversation history maintained in session
3. Markdown support for AI responses
4. Error handling with retry capability
5. Clean, modern SwiftUI interface
6. Accessibility support
7. Dark mode support

## Technical Considerations
- Use Swift Concurrency (async/await)
- Implement proper error handling for model unavailability
- Handle device compatibility (Apple Intelligence requires A17 Pro or later)
- Optimize for performance with streaming responses
