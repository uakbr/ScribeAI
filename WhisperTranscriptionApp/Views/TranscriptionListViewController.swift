import UIKit
import CoreData
import AuthenticationServices
import Supabase

class TranscriptionListViewController: UITableViewController {
    private var dataSource: UITableViewDiffableDataSource<Section, TranscriptionRecord>?
    private var loadingSpinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        setupRefreshControl()
        setupEmptyState()
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, transcription in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TranscriptionCell",
                    for: indexPath
                ) as? TranscriptionCell
                cell?.configure(with: transcription)
                return cell
            }
        )
    }
    
    private func updateDataSource(with transcriptions: [TranscriptionRecord]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, TranscriptionRecord>()
        snapshot.appendSections([.main])
        snapshot.appendItems(transcriptions)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    enum Section {
        case main
    }
} 