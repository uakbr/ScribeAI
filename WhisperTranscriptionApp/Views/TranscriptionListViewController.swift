import UIKit
import CoreData
import SwiftUI

class TranscriptionListViewController: UIViewController {
    private var transcriptions: [TranscriptionRecord] = []
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No transcriptions yet. Start recording to create one."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTranscriptions()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidChange),
            name: .NSManagedObjectContextObjectsDidChange,
            object: nil
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Transcriptions"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TranscriptionCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshTranscriptions), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func refreshTranscriptions() {
        fetchTranscriptions()
        refreshControl.endRefreshing()
    }
    
    private func fetchTranscriptions() {
        transcriptions = CoreDataStack.shared.fetchRecentTranscriptions(limit: 0)
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !transcriptions.isEmpty
        tableView.isHidden = transcriptions.isEmpty
    }
    
    @objc private func contextDidChange(_ notification: Notification) {
        fetchTranscriptions()
    }
}

extension TranscriptionListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transcriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let transcription = transcriptions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TranscriptionCell", for: indexPath)
        cell.textLabel?.text = transcription.text?.prefix(50).appending("...") ?? "No Text"
        cell.detailTextLabel?.text = transcription.date?.formatted() ?? ""
        cell.accessibilityLabel = "Transcription from \(transcription.date?.formatted() ?? "unknown date")"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transcription = transcriptions[indexPath.row]
        let transcriptionView = TranscriptionView(viewModel: TranscriptionViewModel(transcription: transcription))
        let hostingController = UIHostingController(rootView: transcriptionView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
} 