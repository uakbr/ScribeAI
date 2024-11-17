import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var slides: [OnboardingSlide] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSlides()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupSlides() {
        slides = [
            OnboardingSlide(title: "Welcome", description: "Transcribe your thoughts effortlessly.", imageName: "onboarding1"),
            OnboardingSlide(title: "Record", description: "Record audio seamlessly.", imageName: "onboarding2"),
            OnboardingSlide(title: "Transcribe", description: "Get accurate transcriptions in real-time.", imageName: "onboarding3"),
            OnboardingSlide(title: "Manage", description: "Save and manage your transcriptions.", imageName: "onboarding4", action: getStartedTapped)
        ]
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .systemBlue
        
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        
        setupConstraints()
        setupSlideViews()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupSlideViews() {
        for (index, slide) in slides.enumerated() {
            let slideView = slide.createView(target: self, actionSelector: #selector(getStartedTapped))
            slideView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(slideView)
            
            NSLayoutConstraint.activate([
                slideView.widthAnchor.constraint(equalTo: view.widthAnchor),
                slideView.heightAnchor.constraint(equalTo: view.heightAnchor),
                slideView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(index) * view.frame.width),
                slideView.topAnchor.constraint(equalTo: scrollView.topAnchor)
            ])
        }
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
    }
    
    // MARK: - Actions
    @objc private func getStartedTapped() {
        // Transition to the main interface or login screen
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
} 