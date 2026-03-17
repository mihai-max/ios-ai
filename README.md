# iOS AI - Apple Foundation Models Chat App

A SwiftUI-based iOS app that allows users to have conversations with Apple's on-device Foundation Models (Apple Intelligence).

## Features

- **On-Device AI**: Powered by Apple Intelligence Foundation Models running locally on your device (iOS 18+)
- **Simulation Mode**: Works on iOS 17+ with simulated responses for testing the UI
- **Private & Secure**: All processing happens on-device - no data is sent to external servers
- **Streaming Responses**: Real-time streaming of AI responses as they're generated
- **Markdown Support**: AI responses support markdown formatting
- **Modern UI**: Clean, intuitive SwiftUI interface with dark mode support
- **Conversation History**: Maintains chat history within the session
- **Error Handling**: Graceful error handling with retry capability

## Requirements

- iOS 17.0 or later (minimum deployment target)
- **For full AI features**: iOS 18.0+ and iPhone 15 Pro or later (A17 Pro chip required for Apple Intelligence)
- Apple Intelligence enabled in Settings (iOS 18+ only)

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

```
iOSAI/
├── Models/
│   └── ChatMessage.swift       # Message data model
├── ViewModels/
│   └── ChatViewModel.swift     # Business logic and Foundation Models integration
├── Views/
│   ├── ChatBubbleView.swift    # Individual message bubble
│   ├── MessageInputView.swift  # Text input field
│   └── TypingIndicatorView.swift # Loading indicator
├── ContentView.swift           # Main chat interface
└── iOSAIApp.swift              # App entry point
```

## Key Components

### ChatMessage Model
- Represents individual chat messages
- Supports user messages, AI responses, and error states
- Includes metadata like timestamp and status

### ChatViewModel
- Manages chat state and interactions
- Integrates with Apple Foundation Models via `LanguageModelSession`
- Handles streaming responses
- Provides error handling and retry functionality

### Views
- **ChatBubbleView**: Displays messages with different styling for user/AI
- **MessageInputView**: Text input with send button and character limit
- **TypingIndicatorView**: Animated dots indicating AI is processing
- **ContentView**: Main container with navigation and message list

## Usage

1. Launch the app
2. Type your message in the input field
3. Tap the send button or press return
4. Watch as the AI responds in real-time
5. Long-press on messages to copy them

### Simulation Mode (iOS 17)

On iOS 17 or devices without Apple Intelligence, the app runs in simulation mode:
- A banner indicates simulation mode is active
- Responses are simulated to demonstrate the UI
- Full AI capabilities require iOS 18+ with Apple Intelligence

## Apple Intelligence Setup (iOS 18+)

To use full AI features on iOS 18+:

1. Have a compatible device (iPhone 15 Pro or later with A17 Pro chip)
2. Update to iOS 18 or later
3. Enable Apple Intelligence in Settings:
   - Go to Settings > Apple Intelligence & Siri
   - Enable Apple Intelligence
   - Wait for the model to download (may take some time)

## Development

### Building the Project

1. Open the project in Xcode 16 or later
2. Select your target device (must support Apple Intelligence)
3. Build and run (Cmd+R)

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme iOSAI -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run specific test
xcodebuild test -scheme iOSAI -only-testing:iOSAITests/ChatViewModelTests
```

### Code Style

- Swift 5.9+ with strict concurrency
- SwiftUI for all views
- `@Observable` macro for view models
- Async/await for asynchronous operations

## API Reference

### Foundation Models Framework

The app uses the following APIs from the `FoundationModels` framework:

- `SystemLanguageModel`: Access to the on-device language model
- `LanguageModelSession`: Session for maintaining conversation context
- `streamResponse(to:)`: Streaming response generation

## Privacy

This app:
- Does not collect any user data
- Does not require internet connectivity for AI features
- Processes all data on-device
- Does not include any analytics or tracking

## License

This project is licensed under the GNU Lesser General Public License v2.1 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Built with Apple's Foundation Models framework
- Designed for iOS 18 and Apple Intelligence
