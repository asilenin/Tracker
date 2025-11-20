import UIKit

protocol StatisticsPresenterProtocol {
    var viewController: StatisticsViewControllerProtocol? { get set }
}

final class StatisticsPresenter: StatisticsPresenterProtocol {
    
    // MARK: - Public Properties
    weak var viewController: StatisticsViewControllerProtocol?
    
    // MARK: - Lifecycle
    func viewDidLoad(){
    }
}
