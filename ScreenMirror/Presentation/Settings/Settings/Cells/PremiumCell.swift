import UIKit
import SnapKit
import ShadowImageButton
import Utilities

class PremiumCell: UITableViewCell {
    static let reuseID = "PremiumCell"
    
    private let containerView: UIImageView = {
        let view = UIImageView(image: .init(named: "promotionCellBackground"))
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
    }()
    
    private let leftImageView: UIImageView = {
        UIImageView(image: UIImage(named: "promotion"))
    }()
    
    private let promotionTitle: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 20)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Explore premium".localized
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let promotionSubtitle: UILabel = {
        let label = UILabel()
        
        label.font = .font(weight: .regular, size: 14)
        label.textAlignment = .left
        label.textColor = .white.withAlphaComponent(0.9)
        label.text = "Unlock all features".localized
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start now".localized, for: .normal)
        button.titleLabel?.font = .font(weight: .bold, size: 16)
        button.setTitleColor(UIColor(hex: "1E0404"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.applyDropShadow(
            color: .white,
            opacity: 0.6,
            offset: CGSize(width: 0, height: 4),
            radius: 21
        )
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(promotionTitle, promotionSubtitle, actionButton, leftImageView)
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.verticalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(192)
        }
        
        promotionTitle.snp.makeConstraints {
            $0.leading.equalTo(actionButton)
            $0.width.equalTo(170)
            $0.top.equalToSuperview().inset(18)
        }
        
        promotionSubtitle.snp.makeConstraints {
            $0.leading.equalTo(actionButton)
            $0.width.equalTo(170)
            $0.top.equalTo(promotionTitle.snp.bottom).offset(4)
        }
        
        actionButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(159)
            $0.bottom.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 109, height: 33))
        }
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 147, height: 130))
        }
    }
}

// MARK: - Extensions

extension UIView {
    func applyDropShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}
