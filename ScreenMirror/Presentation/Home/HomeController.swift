import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities

class HomeController: BaseController {
    
    private let navigationTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureNavigation()
    }
    
    private func configureViewHierarchy() {

    }
    
    private func configureNavigation() {
        navigationTitle.text = "Home".localized
        navigationTitle.font = .font(weight: .bold, size: 25)
        configurNavigation(leftView: navigationTitle)
    }
}
