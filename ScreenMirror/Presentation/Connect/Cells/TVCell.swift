import UIKit
import SnapKit
import Utilities
import CocoaUPnP

final class TVCell: UITableViewCell {
    
    static let reuseID = "TVCell"
    
    private lazy var customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "6B6B6B").withAlphaComponent(0.1)
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "494949")
        return view
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "selection"))
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .semiBold, size: 18)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .regular, size: 14)
        label.textColor = .init(hex: "959595")
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(customBackgroundView)
        
        customBackgroundView.addSubview(rightImageView)
        customBackgroundView.addSubview(stackView)
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(17)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(33)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(27)
            make.right.equalToSuperview().inset(67)
            make.centerY.equalToSuperview()
        }
        
        customBackgroundView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func configure(tv: UPPMediaRendererDevice, isLast: Bool, isFirst: Bool) {
        
        titleLabel.text = tv.friendlyName
        
        let isConnected = DLNAContentManager.shared.currentDevice == tv
        rightImageView.isHidden = !isConnected
        subtitleLabel.text = isConnected ? "Connected".localized : "Not connected".localized
        subtitleLabel.textColor = UIColor.init(hex: "959595")
        
        if isLast && isFirst {
            separatorView.isHidden = true
            customBackgroundView.layer.cornerRadius = 20
        } else if isLast {
            separatorView.isHidden = true
            customBackgroundView.layer.cornerRadius = 20
            customBackgroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            separatorView.isHidden = false
            customBackgroundView.layer.cornerRadius = 20
            customBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            separatorView.isHidden = false
            customBackgroundView.layer.cornerRadius = 0
        }
    }
}
