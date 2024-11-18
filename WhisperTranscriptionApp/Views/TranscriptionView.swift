import SwiftUI

struct TranscriptionView: View {
    @ObservedObject var viewModel: TranscriptionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(viewModel.transcriptionText)
                    .font(.body)
                    .padding()
                    .accessibilityLabel("Transcription text")
                    .accessibilityValue(viewModel.transcriptionText)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
                    .accessibilityLabel("Loading transcription")
            }
            
            HStack(spacing: 20) {
                Button(action: viewModel.shareTranscription) {
                    Label(L10n.Transcription.share, systemImage: "square.and.arrow.up")
                }
                .accessibilityHint("Shares the transcription")
                
                Button(action: viewModel.copyToClipboard) {
                    Label(L10n.Transcription.copy, systemImage: "doc.on.doc")
                }
                .accessibilityHint("Copies the transcription to clipboard")
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Transcription")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.deleteTranscription) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel(L10n.Transcription.delete)
                .accessibilityHint("Deletes this transcription")
            }
        }
    }
} 