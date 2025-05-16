import UIKit
import SnapKit
import ShadowImageButton
import Utilities
import Lottie

final class ConnectHeaderCell: UITableViewCell {
    
    static let reuseID = "ConnectHeaderCell"
    
    private let centerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "notFound"))
        return imageView
    }()

    private lazy var animationView: LottieAnimationView = {
        let path = Bundle.main.path(
            forResource: "searching",
            ofType: "json"
        ) ?? ""
        let animationView = LottieAnimationView(filePath: path)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
        return animationView
    }()
    
    private lazy var connectionTitleLabel = UILabel().apply {
        $0.font = .font(weight: .bold, size: 20)
        $0.text = "Looking for your device".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .white
    }
    
    private lazy var connectionSubtitleLabel = UILabel().apply {
        $0.font = .font(weight: .regular, size: 16)
        $0.textColor = .init(hex: "959595")
        $0.text = "Your phone and TV must be on the same WI-FI network".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionStackView = UIStackView(arrangedSubviews: [
        connectionTitleLabel,
        connectionSubtitleLabel
    ]).apply {
        $0.axis = .vertical
        $0.spacing = 15
    }

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
        
        contentView.addSubview(animationView)
        contentView.addSubview(connectionStackView)
        contentView.addSubview(centerImageView)
       
        animationView.snp.makeConstraints { make in
            make.height.width.equalTo(318.0)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(40)
        }
        
        centerImageView.snp.makeConstraints { make in
            make.height.width.equalTo(100)
            make.center.equalTo(animationView)
        }
        
        connectionStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(81)
        }
    }
    
    func configure(isNotFound: Bool) {
        connectionTitleLabel.text = isNotFound ? "No TV detected".localized : "Looking for your device".localized
        animationView.isHidden = isNotFound
        centerImageView.isHidden = !isNotFound
    }
}

