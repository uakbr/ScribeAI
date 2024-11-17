import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    // MARK: - UI Elements
    private let transcriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Transcription will appear here..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Recording", for: .normal)
        return button
    }()

    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pause Recording", for: .normal)
        button.isHidden = true // Hidden until recording starts
        return button
    }()

    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop Recording", for: .normal)
        button.isHidden = true // Hidden until recording starts
        return button
    }()

    // MARK: - Properties
    private var recordingStartTime: Date?
    private var timer: Timer?
    private let audioRecorder = AudioRecorder.shared
    private let audioTranscriber = AudioTranscriber.shared
    private var currentTranscription: String = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        // Add subviews
        view.addSubview(transcriptionLabel)
        view.addSubview(timerLabel)
        view.addSubview(recordButton)
        view.addSubview(pauseButton)
        view.addSubview(stopButton)

        // Style labels
        transcriptionLabel.font = UIFont.systemFont(ofSize: 18)
        transcriptionLabel.textColor = .label

        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        timerLabel.textColor = .secondaryLabel

        // Style buttons
        styleButton(recordButton, title: "Start Recording", backgroundColor: .systemRed)
        styleButton(pauseButton, title: "Pause Recording", backgroundColor: .systemOrange)
        styleButton(stopButton, title: "Stop Recording", backgroundColor: .systemGray)

        // Set up constraints
        setupConstraints()

        // Add accessibility identifiers
        recordButton.accessibilityIdentifier = "recordButton"
        pauseButton.accessibilityIdentifier = "pauseButton"
        stopButton.accessibilityIdentifier = "stopButton"
        transcriptionLabel.accessibilityIdentifier = "transcriptionLabel"
        timerLabel.accessibilityIdentifier = "timerLabel"
    }

    private func styleButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }

    private func setupConstraints() {
        transcriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            transcriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            transcriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            transcriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            timerLabel.topAnchor.constraint(equalTo: transcriptionLabel.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            recordButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 30),
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            pauseButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 15),
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stopButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 15),
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseRecording), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
    }

    @objc private func startRecording() {
        do {
            try audioRecorder.startRecording()
            try audioTranscriber.startTranscribing(
                updateHandler: { [weak self] transcriptionChunk in
                    DispatchQueue.main.async {
                        self?.updateTranscriptionLabel(with: transcriptionChunk)
                    }
                },
                errorHandler: { [weak self] error in
                    DispatchQueue.main.async {
                        ErrorAlertManager.shared.handleTranscriptionError(error, in: self)
                    }
                }
            )
            recordingStartTime = Date()
            startTimer()
            
            // Start Dynamic Island Live Activity
            DynamicIslandController.shared.startDynamicIsland(sessionName: "Transcription Session")
            
            recordButton.isHidden = true
            pauseButton.isHidden = false
            stopButton.isHidden = false
        } catch {
            ErrorAlertManager.shared.handleRecordingError(error, in: self)
        }
    }

    @objc private func pauseRecording() {
        audioRecorder.pauseRecording()
        pauseTimer()
        pauseButton.isHidden = true
        recordButton.isHidden = false
    }

    @objc private func stopRecording() {
        do {
            try audioRecorder.stopRecording()
            audioTranscriber.stopTranscribing()
            stopTimer()
            
            guard let duration = recordingStartTime.map({ Date().timeIntervalSince($0) }) else { return }
            
            // Save transcription to Supabase
            guard let userID = SupabaseManager.shared.client.auth.session?.user.id else {
                // Handle unauthenticated state
                return
            }
            
            let transcriptionRecord = [
                "user_id": userID.uuidString,
                "text": currentTranscription.trimmingCharacters(in: .whitespacesAndNewlines),
                "date": Date().iso8601String,
                "duration": duration,
                "audio_url": "" // Handle audio file upload separately if needed
            ] as [String: Any]
            
            SupabaseManager.shared.client.database
                .from("transcriptions")
                .insert(values: transcriptionRecord)
                .execute { result in
                    switch result {
                    case .success:
                        // Handle success
                        break
                    case .failure(let error):
                        ErrorAlertManager.shared.showAlert(
                            title: "Save Error",
                            message: error.localizedDescription,
                            in: self
                        )
                    }
                }
            
            // End Dynamic Island Live Activity
            DynamicIslandController.shared.endDynamicIsland()
            
            resetUI()
        } catch {
            // Handle errors during stop recording and saving
            ErrorAlertManager.shared.handleRecordingError(error, in: self)
        }
    }

    private func resetUI() {
        recordButton.isHidden = false
        pauseButton.isHidden = true
        stopButton.isHidden = true
        transcriptionLabel.text = "Transcription will appear here..."
        currentTranscription = ""
    }

    private func updateTranscriptionLabel(with transcriptionChunk: String) {
        // Append the new transcription chunk to the current transcription
        currentTranscription += transcriptionChunk + " "

        // Formatting for font size and line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attributedText = NSAttributedString(string: currentTranscription, attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle
        ])
        transcriptionLabel.attributedText = attributedText
    }

    private func showErrorAlert(_ error: Error) {
        ErrorAlertManager.shared.showAlert(
            title: "Error",
            message: error.localizedDescription
        )
    }

    // MARK: - Timer Methods
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }

    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerLabel.text = "00:00"
    }

    @objc private func updateTimerLabel() {
        guard let startTime = recordingStartTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        // Update Dynamic Island with elapsed time and transcription progress
        DynamicIslandController.shared.updateDynamicIsland(
            elapsedTime: elapsedTime,
            transcriptionProgress: currentTranscription
        )
    }

    // MARK: - Deinitialization
    deinit {
        timer?.invalidate()
    }
}