import UIKit

protocol PageViewControllerFactoryProtocol {
    var numberOfPages: Int { get }
    func getViewControllerIndex(of: UIViewController) -> Int?
    func getViewController(at index: Int) -> UIViewController?
}

final class PageViewControllerFactory {
    private var viewControllres: [UIViewController] = ColorPageType.allCases.compactMap { $0.viewController }
}

extension PageViewControllerFactory: PageViewControllerFactoryProtocol {
    var numberOfPages: Int { return ColorPageType.allCases.count }

    func getViewController(at index: Int) -> UIViewController? {
        viewControllres[safe: index]
    }
    
    func getViewControllerIndex(of viewController: UIViewController) -> Int? {
        viewControllres.firstIndex(of: viewController)
    }
}
