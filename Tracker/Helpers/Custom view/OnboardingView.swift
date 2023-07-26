import UIKit

protocol OnboardingViewDelegate: AnyObject {
    func onboardingButtonTapped()
}

final class OnboardingView: UIView {
    
    //MARK: - delegate
    weak var delegate: OnboardingViewDelegate?
    
    //MARK: - viewConstants
    private struct viewConstants {
        static let okButtonTitle = "Вот это технологии!"
    }
    
    // MARK: - UI
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypBlack
        label.font = UIFont.ypBoldSize32
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var okButton: TrackerButton = {
        let button = TrackerButton(
            frame: .zero,
            title: viewConstants.okButtonTitle
        )
        button.addTarget(
            self,
            action: #selector(okButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - initialization
    init(frame: CGRect, imageNamed: String?, infoLabelText: String?) {
        super.init(frame: frame)
        setupView()
        addSubview()
        activateConstraints()
        
        guard let imageNamed else { return }
        let image = UIImage(named: imageNamed)
        backgroundImageView.image = image
        infoLabel.text = infoLabelText
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - private methods
    private func setupView() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubview() {
        addSubViews(
            backgroundImageView,
            infoLabel,
            okButton
        )
    }
    
    private func activateConstraints() {
        let infoLabelSideConstants: CGFloat = 14
        let infoLabelTopConstants: CGFloat = self.frame.height / 2
        let okButtonConstants: CGFloat = 20
        let okButtonButtonConstants: CGFloat = self.frame.height / 9.5
        let okButtonHeight: CGFloat = 65
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: infoLabelSideConstants),
            infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -infoLabelSideConstants),
            infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: infoLabelTopConstants),
            
            okButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: okButtonConstants),
            okButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -okButtonConstants),
            okButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -okButtonButtonConstants),
            okButton.heightAnchor.constraint(equalToConstant: okButtonHeight)
        ])
    }
    
    @objc
    private func okButtonTapped() {
        okButton.showAnimation { [weak self] in
            guard let self = self else { return }
            self.delegate?.onboardingButtonTapped()
        }
    }
}

