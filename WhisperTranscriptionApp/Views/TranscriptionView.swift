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
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .accessibilityHint("Shares the transcription")
                
                Button(action: viewModel.copyToClipboard) {
                    Label("Copy", systemImage: "doc.on.doc")
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
                .accessibilityLabel("Delete")
                .accessibilityHint("Deletes this transcription")
            }
        }
    }
} 

// Sample ViewModel
class TranscriptionViewModel: ObservableObject {
    @Published var transcriptionText: String = ""
    @Published var isLoading: Bool = false

    func shareTranscription() {
        // Implement share functionality
    }

    func copyToClipboard() {
        // Implement copy to clipboard functionality
    }

    func deleteTranscription() {
        // Implement delete functionality
    }
} 