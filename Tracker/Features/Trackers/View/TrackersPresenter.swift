import UIKit

protocol TrackersPresenterProtocol {
    var viewController: TrackersViewControllerProtocol? { get set }
}

final class TrackersPresenter: TrackersPresenterProtocol {
    
    // MARK: - Public Properties
    weak var viewController: TrackersViewControllerProtocol?
    
    // MARK: - Lifecycle
    func viewDidLoad(){
    }
}
