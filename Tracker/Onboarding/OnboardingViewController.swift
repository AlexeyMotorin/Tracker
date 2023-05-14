import UIKit

final class OnboardingViewController: UIViewController {
    
    //MARK: - private properties
    private var backgroundImageName: String?
    private var onboardingInfoText: String?
    
    //MARK: UI
    private lazy var onboardingView: OnboardingView = {
        let view = OnboardingView(
            frame: view.frame,
            imageNamed: backgroundImageName,
            infoLabelText: onboardingInfoText)
        view.delegate = self
        return view
    }()
    
    // MARK: - initialization
    init(backgroundImageName: String, onboardingInfoText: String ) {
        self.backgroundImageName = backgroundImageName
        self.onboardingInfoText = onboardingInfoText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addViews()
        activateConstraints()
    }
    
    //MARK: - private methods
    private func setupView() {
        view.backgroundColor = .clear
    }
    
    private func addViews() {
        view.addSubview(onboardingView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
           onboardingView.topAnchor.constraint(equalTo: view.topAnchor),
           onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
           onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           onboardingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: OnboardingViewDelegate
extension OnboardingViewController: OnboardingViewDelegate {
    func onboardingButtonTapped() {
        print("delegate")
    }
}
