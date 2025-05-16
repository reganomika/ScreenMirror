import UIKit
import SnapKit
import CustomBlurEffectView

protocol ScreenMirrorSettingSelectionControllerDelegate: AnyObject {
    func didSelected(type: ScreenMirrorSelectionType, index: Int)
}

final class ScreenMirrorSettingSelectionController: UIViewController {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let blurRadius: CGFloat = 3
        static let blurColor = UIColor(hex: "171313")
        static let blurAlpha: CGFloat = 0.3
        
        static let contentBackground = UIColor(hex: "1E1E1E")
        static let cornerRadius: CGFloat = 25
        static let contentHeight: CGFloat = 351
        
        static let titleFontSize: CGFloat = 22
        static let titleTopInset: CGFloat = 38
        static let horizontalInset: CGFloat = 22
        
        static let closeButtonSize: CGFloat = 31
        static let closeButtonInset: CGFloat = 21
        static let closeButtonRightInset: CGFloat = 18
        
        static let collectionViewHeight: CGFloat = 161
        static let collectionViewBottomInset: CGFloat = 78
        static let collectionViewTotalWidth: CGFloat = 344
        static let itemSize: CGFloat = 161
        static let minimumLineSpacing: CGFloat = 22
        
    }
    
    private let type: ScreenMirrorSelectionType
    private let selectedRow: Int
    private weak var delegate: ScreenMirrorSettingSelectionControllerDelegate?
    
    init(type: ScreenMirrorSelectionType, selectedRow: Int, delegate: ScreenMirrorSettingSelectionControllerDelegate?) {
        self.selectedRow = selectedRow
        self.type = type
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        self.titleLabel.text = type.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    private lazy var blurView = CustomBlurEffectView().apply {
        $0.blurRadius = LayoutConstants.blurRadius
        $0.colorTint = LayoutConstants.blurColor
        $0.colorTintAlpha = LayoutConstants.blurAlpha
    }
    
    private lazy var contentView = UIView().apply {
        $0.backgroundColor = LayoutConstants.contentBackground
        $0.layer.cornerRadius = LayoutConstants.cornerRadius
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private lazy var titleLabel = UILabel().apply {
        $0.text = "Change icon".localized
        $0.font = .font(weight: .bold, size: LayoutConstants.titleFontSize)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var closeButton = UIButton().apply {
        $0.setImage(.close, for: .normal)
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BaseCell.self, forCellReuseIdentifier: BaseCell.reuseID)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(blurView)
        blurView.addSubview(contentView)
        contentView.addSubviews(titleLabel, closeButton, tableView)
    }
    
    private func setupConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(LayoutConstants.contentHeight)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(LayoutConstants.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(LayoutConstants.horizontalInset)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(LayoutConstants.closeButtonSize)
            $0.top.equalToSuperview().inset(LayoutConstants.closeButtonInset)
            $0.trailing.equalToSuperview().inset(LayoutConstants.closeButtonRightInset)
        }
            
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(96)
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss(animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ScreenMirrorSettingSelectionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return type.values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BaseCell.reuseID,
            for: indexPath
        ) as! BaseCell
        
        cell.configure(value: type.values[indexPath.row], isSelected: indexPath.row == selectedRow)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        delegate?.didSelected(type: type, index: indexPath.row)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        76.0
    }
}
