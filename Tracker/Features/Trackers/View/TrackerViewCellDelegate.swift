import Foundation

protocol TrackerViewCellDelegate: AnyObject {
    func didTapCompleteButton(trackerId: UUID, at indexPath: IndexPath)
    func didTapUnCompleteButton(trackerId: UUID, at indexPath: IndexPath)
}
