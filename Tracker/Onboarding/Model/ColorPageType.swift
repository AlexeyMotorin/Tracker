import UIKit

enum ColorPageType: CaseIterable {
    case blue
    case red
 
    var viewController: UIViewController {
        switch self {
        case .blue:
            return OnboardingViewController(colorPage: self.colorPage)
        case .red:
            return OnboardingViewController(colorPage: self.colorPage)
        }
    }

    private var colorPage: ColorPage {
        ColorPage(backgroundImageName: self.imageName, onboardingInfoText: self.infoText)
    }
    
    private var imageName: String {
        switch self {
        case .blue:
            return "BlueOnboardingBackground"
        case .red:
            return "RedOnboardingBackground"
        }
    }
    
    private var infoText: String {
        switch self {
        case .blue:
            return "Отслеживайте только то, что хотите"
        case .red:
            return "Даже если это не литры воды и йога"
        }
    }
}
