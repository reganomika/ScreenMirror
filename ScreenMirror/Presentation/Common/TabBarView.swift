import UIKit
import SnapKit
import Utilities

protocol TabBarViewDelegate: AnyObject {
    func tabBarView(_ tabBarView: TabBarView, didSelectItemAt index: Int)
}

enum TabBarViewItemType {
    case tabItem(selectedImage: UIImage?, unselectedImage: UIImage?, String)
    case centerItem(selectedImage: UIImage?, unselectedImage: UIImage?)
}

final class TabBarView: UIView {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.04)
        view.layer.cornerRadius = 40
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    weak var delegate: TabBarViewDelegate?
    private var tabButtons: [UIView] = []
    private var centerButton: UIView?
    
    private let items: [TabBarViewItemType] = [
        .tabItem(
            selectedImage: UIImage(named: "homeTabSelected"),
            unselectedImage: UIImage(named: "homeTabUnselected"),
            "home".localized
        ),
        .centerItem(
            selectedImage: UIImage(named: "centerTabSelected"),
            unselectedImage: UIImage(named: "centerTab")
        ),
        .tabItem(
            selectedImage: UIImage(named: "settingsTabSelected"),
            unselectedImage: UIImage(named: "settingsTabUnselected"),
            "settings".localized
        )
    ]

    init() {
        super.init(frame: .zero)
        setupTabBarButtons()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTabBarButtons() {
        if case let .tabItem(selectedImage, unselectedImage, title) = items[0] {
            let button = createTabButton(
                selectedImage: selectedImage,
                unselectedImage: unselectedImage,
                title: title,
                tag: 0
            )
            contentView.addSubview(button)
            tabButtons.append(button)
        }
        
        if case let .centerItem(selectedImage, unselectedImage) = items[1] {
            let button = createCenterButton(
                selectedImage: selectedImage,
                unselectedImage: unselectedImage,
                tag: 1
            )
            addSubview(button)
            centerButton = button
        }
        
        if case let .tabItem(selectedImage, unselectedImage, title) = items[2] {
            let button = createTabButton(
                selectedImage: selectedImage,
                unselectedImage: unselectedImage,
                title: title,
                tag: 2
            )
            contentView.addSubview(button)
            tabButtons.append(button)
        }
        
        updateSelectedButton(at: 0)
    }
    
    private func createTabButton(
        selectedImage: UIImage?,
        unselectedImage: UIImage?,
        title: String,
        tag: Int
    ) -> UIView {
        let container = UIView()
        container.tag = tag
        
        let imageView = UIImageView(image: unselectedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        
        let label = GradientLabel()
        label.label.text = title
        label.label.font = .font(weight: .semiBold, size: 14)
        label.tag = 101
        
        container.addSubview(imageView)
        container.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabButtonTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        
        return container
    }
    
    private func createCenterButton(
        selectedImage: UIImage?,
        unselectedImage: UIImage?,
        tag: Int
    ) -> UIView {
        let container = UIView()
        container.tag = tag
        
        let buttonView = UIView()
        buttonView.layer.cornerRadius = 41
        buttonView.tag = 200
        buttonView.backgroundColor = UIColor(hex: "FF4400")
        buttonView.layer.shadowColor = UIColor(hex: "FF4400").cgColor
        buttonView.layer.shadowOpacity = 0.25
        buttonView.layer.shadowOffset = CGSize(width: 0, height: 5)
        buttonView.layer.shadowRadius = 20.5
        
        let imageView = UIImageView(image: unselectedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.tag = 201
        
        container.addSubview(buttonView)
        buttonView.addSubview(imageView)
        
        buttonView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(82)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(82)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabButtonTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        
        return container
    }

    private func setupLayout() {
        insertSubview(contentView, belowSubview: centerButton!)
        
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(30)
            make.height.equalTo(104)
        }
        
        if let leftButton = tabButtons.first {
            leftButton.snp.makeConstraints { make in
                make.left.equalTo(contentView).offset(50)
                make.bottom.equalTo(contentView).offset(-40)
                make.width.equalTo(80)
                make.height.equalTo(50)
            }
        }
        
        if let centerButton = centerButton {
            centerButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.width.height.equalTo(82)
            }
        }
        
        if tabButtons.count > 1, let rightButton = tabButtons.last {
            rightButton.snp.makeConstraints { make in
                make.right.equalTo(contentView).offset(-50)
                make.bottom.equalTo(contentView).offset(-40)
                make.width.equalTo(80)
                make.height.equalTo(50)
            }
        }
    }

    @objc private func tabButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedIndex = sender.view?.tag else { return }
        updateSelectedButton(at: selectedIndex)
        delegate?.tabBarView(self, didSelectItemAt: selectedIndex)
    }

    private func updateSelectedButton(at index: Int) {
        
        if index == 1 {
            return
        }

        if case let .tabItem(selectedImage, unselectedImage, _) = items[0] {
            let button = tabButtons[0]
            let imageView = button.viewWithTag(100) as! UIImageView
            let label = button.viewWithTag(101) as! GradientLabel
            
            let isSelected = index == 0
            imageView.image = isSelected ? selectedImage : unselectedImage
            if isSelected {
                label.setLabelColor()
            } else {
                label.setLabelColor(plainColor: UIColor(hex: "959595"))
            }
        }
    
        if case let .tabItem(selectedImage, unselectedImage, _) = items[2] {
            let button = tabButtons[1]
            let imageView = button.viewWithTag(100) as! UIImageView
            let label = button.viewWithTag(101) as! GradientLabel
            
            let isSelected = index == 2
            imageView.image = isSelected ? selectedImage : unselectedImage
            
            if isSelected {
                label.setLabelColor()
            } else {
                label.setLabelColor(plainColor: UIColor(hex: "959595"))
            }
        }
    }
}
