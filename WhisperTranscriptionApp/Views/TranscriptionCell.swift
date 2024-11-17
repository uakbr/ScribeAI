import UIKit

class TranscriptionCell: UITableViewCell {
    static let identifier = "TranscriptionCell"
    
    // MARK: - UI Elements
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.accessibilityIdentifier = "dateLabel"
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.accessibilityIdentifier = "durationLabel"
        return label
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 2
        label.accessibilityIdentifier = "previewLabel"
        return label
    }()
    
    private let stackView = UIStackView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(durationLabel)
        stackView.addArrangedSubview(previewLabel)
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with transcription: Transcription) {
        dateLabel.text = transcription.dateFormattedString()
        durationLabel.text = String(format: "Duration: %.1f seconds", transcription.duration)
        if let text = transcription.text, !text.isEmpty {
            previewLabel.text = text.count > 100 ? String(text.prefix(100)) + "..." : text
        } else {
            previewLabel.text = "No transcription available."
        }
    }
} 