import UIKit

class SettingsViewController: UIViewController {
    // Added a 'Privacy Policy' section
    let privacyPolicyButton = UIButton(type: .system)
    let deleteDataButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set titles for buttons
        privacyPolicyButton.setTitle("Privacy Policy", for: .normal)
        deleteDataButton.setTitle("Delete All Data", for: .normal)
        
        // Add buttons to the view
        view.addSubview(privacyPolicyButton)
        view.addSubview(deleteDataButton)
        
        // Set up constraints or frames for buttons
        setupButtonConstraints()
        
        // Add targets for buttons
        privacyPolicyButton.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
        deleteDataButton.addTarget(self, action: #selector(confirmDeleteData), for: .touchUpInside)
    }
    
    // MARK: - Button Constraints
    private func setupButtonConstraints() {
        privacyPolicyButton.translatesAutoresizingMaskIntoConstraints = false
        deleteDataButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Privacy Policy Button Constraints
            privacyPolicyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyPolicyButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            // Delete Data Button Constraints
            deleteDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteDataButton.topAnchor.constraint(equalTo: privacyPolicyButton.bottomAnchor, constant: 20)
        ])
    }

    // Implemented actions
    @objc private func showPrivacyPolicy() {
        // Present privacy policy
        let privacyVC = PrivacyPolicyViewController()
        navigationController?.pushViewController(privacyVC, animated: true)
    }

    @objc private func confirmDeleteData() {
        // Confirm and delete user data
        let alert = UIAlertController(
            title: "Delete All Data",
            message: "Are you sure you want to delete all your data?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Perform data deletion
            DataManager.shared.deleteAllData()
        })
        present(alert, animated: true)
    }
} u