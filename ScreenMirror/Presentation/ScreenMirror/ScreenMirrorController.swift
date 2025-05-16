import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import CocoaUPnP
import ShadowImageButton

class ScreenMirrorController: BaseController {
        
    private enum Constants {
        static let shadowRadius: CGFloat = 14.7
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let shadowOpacity: Float = 0.6
    }
    
    // MARK: - UI Elements
    private let navigationTitle = UILabel()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var topButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    private lazy var shadowImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "shadow"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var startButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Start".localized,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "promotionCellBackground"),
                cornerRadius: 18.0,
                shadowConfig: .init(
                    color: UIColor(hex: "FF8350"),
                    opacity: Constants.shadowOpacity,
                    offset: Constants.shadowOffset,
                    radius: Constants.shadowRadius
                )
            )
        )
        $0.action = { [weak self] in self?.start() }
    }
    
    private lazy var faqButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Need help?".localized,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: UIImage(named: "faqButtonImage")
            ),
            backgroundImageConfig: .init(
                image: UIImage(named: "transparentButtonBackground"),
                cornerRadius: 18,
                shadowConfig: nil
            )
        )
        $0.action = { [weak self] in self?.openFAQ() }
    }
    
    // MARK: - Properties
    private let viewModel = ScreenMirrorViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureNavigation()
        setupBindings()
        viewModel.configureCells()
    }
    
    // MARK: - Setup
    private func configureViewHierarchy() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BaseCell.self, forCellReuseIdentifier: BaseCell.reuseID)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(
            top: 30,
            left: 0,
            bottom: 150,
            right: 0
        )
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        view.addSubview(shadowImageView)
        
        shadowImageView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(221)
        }
        
        view.addSubview(faqButton)
        
        faqButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(27)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(69)
        }
        
        view.addSubview(startButton)
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(116)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(69)
        }
    }
    
    private func configureNavigation() {
        navigationTitle.text = viewModel.device?.friendlyName
        navigationTitle.font = .font(weight: .bold, size: 25)
        configurNavigation(
            centerView: navigationTitle,
            rightView: topButton
        )
    }
    
    private func setupBindings() {

        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.showAlert = { [weak self] title, message in
            self?.showAlert(title: title, message: message)
        }
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc private func start() {
        viewModel.startCast()
    }
    
    @objc private func openFAQ() {
        present(vc: FAQController(), animated: false)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ScreenMirrorController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BaseCell.reuseID,
            for: indexPath
        ) as! BaseCell
        
        cell.configure(type: viewModel.cells[indexPath.row])
        
        cell.onValueChanged = { [weak self] type, value in
            
            guard let self, let type else { return }
            
            switch type {
            case .sound:
                viewModel.isSoundOn = value
                viewModel.configureCells()
            case .autoRotate:
                viewModel.isAutoRotate = value
                viewModel.configureCells()
            default:
                break
            }
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        switch viewModel.cells[indexPath.row] {
        case .value(let type, _):
            switch type {
            case .mirrorTo:
                presentCrossDissolve(
                    vc: ScreenMirrorSettingSelectionController(
                        type: .mirrorTo,
                        selectedRow: MirrorToType.allCases.firstIndex(of: viewModel.mirrorToType) ?? 0,
                        delegate: self
                    )
                )
            case .quality:
                presentCrossDissolve(
                    vc: ScreenMirrorSettingSelectionController(
                        type: .quality,
                        selectedRow: QualityType.allCases.firstIndex(of: viewModel.qualityType) ?? 0,
                        delegate: self
                    )
                )
            default:
                break
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        81.0
    }
}

extension ScreenMirrorController: ScreenMirrorSettingSelectionControllerDelegate {
    func didSelected(type: ScreenMirrorSelectionType, index: Int) {
        switch type {
        case .mirrorTo:
            viewModel.mirrorToType = MirrorToType.init(rawValue: index) ?? .tv
            viewModel.configureCells()
        case .quality:
            viewModel.qualityType = QualityType.init(rawValue: index) ?? .low
            viewModel.configureCells()
        }
    }
}
