import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import CocoaUPnP
import ShadowImageButton

class ConnectController: BaseController {
    
    private enum Constants {
        static let shadowRadius: CGFloat = 14.7
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let shadowOpacity: Float = 0.6
        static let headerCelHeight = 350.0
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
    
    private lazy var refreshButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Refresh".localized,
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
        $0.action = { [weak self] in self?.refresh() }
        $0.isHidden = true
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
    private let viewModel = ConnectViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureNavigation()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startDiscovery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopDiscovery()
    }
    
    // MARK: - Setup
    private func configureViewHierarchy() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset.top = 10
        tableView.register(TVCell.self, forCellReuseIdentifier: TVCell.reuseID)
        tableView.register(ConnectHeaderCell.self, forCellReuseIdentifier: ConnectHeaderCell.reuseID)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(
            top: UIScreen.main.bounds.height / 2 - Constants.headerCelHeight,
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
        
        view.addSubview(refreshButton)
        
        refreshButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(116)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(69)
        }
    }
    
    private func configureNavigation() {
        navigationTitle.text = "Connect your TV".localized
        navigationTitle.font = .font(weight: .bold, size: 25)
        configurNavigation(
            centerView: navigationTitle,
            rightView: topButton
        )
    }
    
    private func setupBindings() {
        viewModel.devicesDidChange = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.refreshButton.isHidden = !self.viewModel.isNotFound
            if self.viewModel.devices.isEmpty == false {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
            }
        }
        
        viewModel.showAlert = { [weak self] title, message in
            self?.showAlert(title: title, message: message)
        }
    }
    
    @objc private func close() {
        viewModel.stopDiscovery()
        dismiss(animated: true)
    }
    
    @objc private func refresh() {
        viewModel.startDiscovery()
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
extension ConnectController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ConnectHeaderCell.reuseID,
                for: indexPath
            ) as! ConnectHeaderCell
            cell.configure(isNotFound: viewModel.isNotFound)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TVCell.reuseID,
            for: indexPath
        ) as! TVCell
        cell.configure(
            tv: viewModel.devices[indexPath.row],
            isLast: indexPath.row == viewModel.devices.count - 1,
            isFirst: indexPath.row == 0
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        viewModel.didSelectDevice(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? Constants.headerCelHeight : 70.0
    }
}
