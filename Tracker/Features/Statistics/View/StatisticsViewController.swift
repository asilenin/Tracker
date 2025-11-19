import UIKit

protocol StatisticsViewControllerProtocol: AnyObject {
    var presenter: StatisticsPresenterProtocol? { get set }
    
}

final class StatisticsViewController: UIViewController & StatisticsViewControllerProtocol{
    
    // MARK: - Properties
    var presenter: StatisticsPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
