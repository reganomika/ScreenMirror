import Utilities
import UIKit
import SnapKit

final class BaseCell: UITableViewCell {
    
    static let reuseID = "BaseCell"
    
    private lazy var customBackgroundView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "baseCellBackground"))
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 18)
        label.textColor = .white
        return label
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
        
        customBackgroundView.addSubview(leftImageView)
        customBackgroundView.addSubview(titleLabel)
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(63)
            make.right.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(type: SettingsOption) {
        titleLabel.text = type.displayTitle
        leftImageView.image = type.iconAsset
    }
}
