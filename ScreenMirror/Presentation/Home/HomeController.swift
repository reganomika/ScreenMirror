import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities

class HomeController: BaseController {
    
    private let navigationTitle = UILabel()
    private let tableView = UITableView()
    
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureNavigation()
    }
    
    private func configureViewHierarchy() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        tableView.register(
            PremiumCell.self,
            forCellReuseIdentifier: PremiumCell.reuseID
        )
        tableView.register(
            BaseCell.self,
            forCellReuseIdentifier: BaseCell.reuseID
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 100
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func configureNavigation() {
        navigationTitle.text = "Screen Mirroring".localized
        navigationTitle.font = .font(weight: .medium, size: 29)
        configurNavigation(leftView: navigationTitle)
    }
}

extension HomeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.cells[indexPath.row] {
        case .connect:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PremiumCell.reuseID,
                for: indexPath
            ) as! PremiumCell
            return cell
        case .screenMirroring:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PremiumCell.reuseID,
                for: indexPath
            ) as! PremiumCell
            return cell
        case .collection(let cellTypes):
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        switch viewModel.cells[indexPath.row] {
        case .connect:
            present(vc: ConnectController(), modalPresentationStyle: .fullScreen)
        case .screenMirroring:
            
            if DLNAContentManager.shared.currentDevice == nil {
                present(vc: ConnectController(), modalPresentationStyle: .fullScreen)
            } else {
                present(vc: ScreenMirrorController(), modalPresentationStyle: .fullScreen)
            }
           
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.cells[indexPath.row] {
        case .connect: return 106.0
        case .screenMirroring: return 106.0
        case .collection: return 318.0
        }
    }
}
