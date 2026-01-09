import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {

    func makeSUT(style: UIUserInterfaceStyle) -> UIViewController {
        let vc = TrackersViewController()
        let nav = UINavigationController(rootViewController: vc)

        nav.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        nav.overrideUserInterfaceStyle = style

        return nav
    }

    func testTrackers_LightMode() {
        let vc = makeSUT(style: .light)

        assertSnapshot(
            of: vc,
            as: .image
        )
    }

    func testTrackers_DarkMode() {
        let vc = makeSUT(style: .dark)

        assertSnapshot(
            of: vc,
            as: .image
        )
    }
}
