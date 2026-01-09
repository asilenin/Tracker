import UIKit

final class TabBarController: UITabBarController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    // MARK: - Tabs
    private func setupTabs() {

        // Trackers
        let trackersViewController = TrackersViewController()
        let trackersNavController = UINavigationController(
            rootViewController: trackersViewController
        )

        trackersNavController.tabBarItem = UITabBarItem(
            title: UIConstants.trackerCollectionViewLabel,
            image: UIImage(resource: .trackersCollectionActive),
            tag: 0
        )

        // Statistics
        let statisticsViewController = StatisticsViewController()
        let statisticsNavController = UINavigationController(
            rootViewController: statisticsViewController
        )

        statisticsNavController.tabBarItem = UITabBarItem(
            title: UIConstants.statisticsViewLabel,
            image: UIImage(resource: .statisticsInactive),
            tag: 0
        )

        viewControllers = [
            trackersNavController,
            statisticsNavController
        ]
    }

    // MARK: - Appearance
    private func setupAppearance() {
        tabBar.backgroundColor = .backgroundTableYP
        tabBar.tintColor = .blueYP
        tabBar.unselectedItemTintColor = .greyYP
    }
}
