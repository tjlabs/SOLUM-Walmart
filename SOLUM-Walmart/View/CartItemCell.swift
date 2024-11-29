import UIKit
import SnapKit
import Kingfisher

class CartItemCell: UICollectionViewCell {
    private let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 8)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardBold(size: 12)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardExtraBold(size: 20)
        label.textColor = UIColor(hex: "#000000")
        label.alpha = 0.6
        
        label.textAlignment = .left
        return label
    }()
    
    private let indicatorBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#5A92E0")
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.layer.cornerRadius = 10
        stackView.distribution = .fillProportionally
        stackView.spacing = 0
        return stackView
    }()
        
    private let buttonMinus: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_minus_white"), for: .normal)
        return button
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.pretendardSemiBold(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let buttonPlus: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_plus_white"), for: .normal)
        return button
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(cellView)
        cellView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        addSubview(productImageView)
        productImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(120)
        }
        
        addSubview(checkboxImageView)
        checkboxImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(5)
            make.width.height.equalTo(30)
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalTo(productImageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(1)
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalToSuperview().inset(20)
        }
        
        addSubview(indicatorBar)
        indicatorBar.snp.makeConstraints { make in
            make.leading.equalTo(productImageView.snp.trailing).offset(20)
            make.bottom.equalToSuperview().inset(10)
            make.width.equalTo(80)
            make.height.equalTo(25)
        }

        indicatorBar.addSubview(buttonMinus)
        indicatorBar.addSubview(quantityLabel)
        indicatorBar.addSubview(buttonPlus)
        
        quantityLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(indicatorBar.snp.width).multipliedBy(0.5)
            make.height.equalToSuperview()
        }
        
        buttonMinus.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.centerY.equalToSuperview()
            make.height.equalTo(indicatorBar.snp.height).offset(-15)
            make.width.equalTo(buttonMinus.snp.height)
        }
        
        buttonPlus.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
            make.height.equalTo(indicatorBar.snp.height).offset(-15)
            make.width.equalTo(buttonPlus.snp.height)
        }
        
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints{ make in
            make.height.equalTo(indicatorBar.snp.height)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(indicatorBar)
        }
        
        // Separator
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    func configure(data: Esl) {
        if let url = URL(string: data.product_url) {
            productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        }
        
        if let checkboxImage = UIImage(named: "ic_checkbox_\(data.color)") {
            checkboxImageView.image = checkboxImage
        }
        
        nameLabel.text = data.product_name
//        descriptionLabel.text = data.product_description
        descriptionLabel.text = "Triscuit Thin Crisps Original Whole Grain Wheat Cracekrs, Vegan Crackers, 7.1 oz"
        quantityLabel.text = "1"
        priceLabel.text = "$\(data.product_price) ea"
    }
}
