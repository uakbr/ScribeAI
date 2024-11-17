import UIKit
import AuthenticationServices

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "app_logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to WhisperTranscriptionApp"
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    
    private let signInButton = UIButton(type: .system)
    private let signUpButton = UIButton(type: .system)
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let appleSignInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Check if user is already signed in
        if let session = SupabaseManager.shared.client.auth.session, session.user != nil {
            presentMainInterface()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure UI Elements
        configureTextFields()
        configureButtons()
        
        // Add subviews
        [logoImageView, titleLabel, emailTextField, passwordTextField, signInButton, signUpButton, orLabel, appleSignInButton, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Setup constraints
        setupConstraints()
    }
    
    private func configureTextFields() {
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.borderStyle = .roundedRect
        emailTextField.textContentType = .username
        emailTextField.autocorrectionType = .no
        emailTextField.delegate = self
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.textContentType = .password
        passwordTextField.delegate = self
    }
    
    private func configureButtons() {
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        signInButton.backgroundColor = .systemBlue
        signInButton.tintColor = .white
        signInButton.layer.cornerRadius = 8
        signInButton.clipsToBounds = true
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        signUpButton.backgroundColor = .systemGreen
        signUpButton.tintColor = .white
        signUpButton.layer.cornerRadius = 8
        signUpButton.clipsToBounds = true
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        
        appleSignInButton.cornerRadius = 8
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignInTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            signInButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 10),
            signUpButton.leadingAnchor.constraint(equalTo: signInButton.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            orLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            orLabel.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
            orLabel.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor),
            
            appleSignInButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 20),
            appleSignInButton.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
            appleSignInButton.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: appleSignInButton.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Button Actions
    @objc private func signInTapped() {
        view.endEditing(true)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            ErrorAlertManager.shared.showAlert(
                title: "Missing Information",
                message: "Please enter both email and password.",
                in: self
            )
            return
        }
        
        activityIndicator.startAnimating()
        
        SupabaseManager.shared.client.auth.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(_):
                    self?.presentMainInterface()
                case .failure(let error):
                    ErrorAlertManager.shared.showAlert(
                        title: "Login Error",
                        message: error.localizedDescription,
                        in: self
                    )
                }
            }
        }
    }
    
    @objc private func signUpTapped() {
        view.endEditing(true)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            ErrorAlertManager.shared.showAlert(
                title: "Missing Information",
                message: "Please enter both email and password.",
                in: self
            )
            return
        }
        
        activityIndicator.startAnimating()
        
        SupabaseManager.shared.client.auth.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let session):
                    let message = session.user?.confirmedAt == nil ? "A verification email has been sent to your email address." : "Sign up successful!"
                    ErrorAlertManager.shared.showAlert(
                        title: "Sign Up",
                        message: message,
                        in: self
                    )
                    if session.user?.confirmedAt != nil {
                        self?.presentMainInterface()
                    }
                case .failure(let error):
                    ErrorAlertManager.shared.showAlert(
                        title: "Sign Up Error",
                        message: error.localizedDescription,
                        in: self
                    )
                }
            }
        }
    }
    
    @objc private func handleAppleSignInTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    // MARK: - Navigation
    private func presentMainInterface() {
        let mainVC = TranscriptionListViewController()
        let navController = UINavigationController(rootViewController: mainVC)
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true)
    }
    
    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Retrieve user identity token
            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                ErrorAlertManager.shared.showAlert(
                    title: "Authentication Error",
                    message: "Unable to retrieve identity token.",
                    in: self
                )
                return
            }
            
            // Sign in with Supabase using the Apple identity token
            SupabaseManager.shared.client.auth.signIn(provider: .apple, credentials: ["id_token": tokenString]) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.presentMainInterface()
                    case .failure(let error):
                        ErrorAlertManager.shared.showAlert(
                            title: "Authentication Error",
                            message: error.localizedDescription,
                            in: self
                        )
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        ErrorAlertManager.shared.showAlert(
            title: "Sign in with Apple Error",
            message: error.localizedDescription,
            in: self
        )
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signInTapped()
        }
        return true
    }
} 