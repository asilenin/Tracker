import UIKit
 
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    private func setupTabs() {
        let statisticsViewController = StatisticsViewController()
        let statisticsPresenter = StatisticsPresenter()
        statisticsViewController.presenter = statisticsPresenter
        statisticsPresenter.viewController = statisticsViewController
        let statisticsNavController = UINavigationController(rootViewController: statisticsViewController)
        
        let trackersCollectionViewController = TrackersViewController()
        let trackersCollectionPresenter = TrackersPresenter()
        trackersCollectionViewController.presenter = trackersCollectionPresenter
        trackersCollectionPresenter.viewController = trackersCollectionViewController
        let trackersNavController = UINavigationController(rootViewController: trackersCollectionViewController)
        
        statisticsNavController.tabBarItem = UITabBarItem(
            title: UIConstants.statisticsViewLabel,
            image: UIImage(resource: .statisticsInactive),
            tag: 1
        )
        
        trackersNavController.tabBarItem = UITabBarItem(
            title: UIConstants.trackerCollectionViewLabel,
            image: UIImage(resource: .trackersCollectionActive),
            tag: 0
        )
        self.viewControllers = [trackersNavController, statisticsNavController]
    }
    
    private func setupAppearance() {
        tabBar.backgroundColor = .whiteYP
        tabBar.tintColor = .blueYP
        tabBar.unselectedItemTintColor = .greyYP
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor.backgroudYP.cgColor
        tabBar.layer.addSublayer(topBorder)
    }
}
