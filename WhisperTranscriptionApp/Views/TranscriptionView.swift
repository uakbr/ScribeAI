import SwiftUI

struct TranscriptionView: View {
    @StateObject private var viewModel: TranscriptionViewModel
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.transcriptionText)
                .font(.body)
                .dynamicTypeSize(...(.accessibility5))
                .accessibilityLabel("Transcription text")
                .accessibilityValue(viewModel.transcriptionText)
            
            if viewModel.isLoading {
                ProgressView()
                    .accessibilityLabel("Loading transcription")
            }
            
            HStack {
                Button(action: viewModel.shareTranscription) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .accessibilityHint("Share this transcription")
                
                Button(action: viewModel.copyToClipboard) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .accessibilityHint("Copy transcription to clipboard")
            }
        }
        .padding()
    }
} 