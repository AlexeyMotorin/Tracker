import UIKit

final class PageViewController: UIPageViewController {
    
    // MARK: - private properties
    private var pagesFactory: PageViewControllerFactoryProtocol?
    
    // MARK: - UI
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pagesFactory?.numberOfPages ?? 0
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        pageControl.isEnabled = false
        return pageControl
    }()
    
    // MARK: - initialization
    init(pagesFactory: PageViewControllerFactoryProtocol) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        self.pagesFactory = pagesFactory
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        addViews()
        activateConstraints()
    }
    
    // MARK: - private methods
    private func setupPageViewController() {
        dataSource = self
        delegate = self
        
        guard let firstViewController = pagesFactory?.firstViewController else { return }
        
        setViewControllers(
            [firstViewController],
            direction: .forward,
            animated: true
        )
    }
    
    private func addViews() {
        view.addSubview(pageControl)
    }
    
    private func activateConstraints() {
        let pageControlTopConstant = view.frame.height / 1.45
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: pageControlTopConstant
            ),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return pagesFactory?.prevViewController
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return pagesFactory?.nextViewController
    }
}

// MARK: UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        pageControl.currentPage = pagesFactory?.currentNumberPage ?? 0
    }
}
