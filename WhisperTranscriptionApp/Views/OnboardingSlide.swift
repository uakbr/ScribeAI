import UIKit

class OnboardingSlide {
    let title: String
    let description: String
    let imageName: String
    var action: (() -> Void)?
    
    init(title: String, description: String, imageName: String, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.action = action
    }
    
    func createView(target: Any, actionSelector: Selector) -> UIView {
        let slideView = UIView()
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        let getStartedButton = UIButton(type: .system)
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        getStartedButton.backgroundColor = .systemBlue
        getStartedButton.tintColor = .white
        getStartedButton.layer.cornerRadius = 8
        getStartedButton.clipsToBounds = true
        getStartedButton.addTarget(target, action: actionSelector, for: .touchUpInside)
        getStartedButton.isHidden = (action == nil)
        
        [imageView, titleLabel, descriptionLabel, getStartedButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            slideView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: slideView.safeAreaLayoutGuide.topAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: slideView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -20),
            
            getStartedButton.bottomAnchor.constraint(equalTo: slideView.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            getStartedButton.leadingAnchor.constraint(equalTo: slideView.leadingAnchor, constant: 50),
            getStartedButton.trailingAnchor.constraint(equalTo: slideView.trailingAnchor, constant: -50),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return slideView
    }
} 