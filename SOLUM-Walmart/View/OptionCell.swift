import UIKit
import SnapKit

class OptionCell: UICollectionViewCell {
    private let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        view.alpha = 0.3
        
        view.borderColor = .systemGray5
        view.borderWidth = 1.2
        
        return view
    }()
        
    private let mainImageView = UIImageView()
    private let uncheckedImageView = UIImageView()
    private let titleLabel = UILabel()

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
            make.top.bottom.leading.trailing.equalToSuperview().inset(0)
        }
        
        mainImageView.contentMode = .scaleAspectFit
        uncheckedImageView.contentMode = .scaleAspectFit
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 8)
        
        addSubview(mainImageView)
        addSubview(uncheckedImageView)
        addSubview(titleLabel)

        uncheckedImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(0)
            make.width.height.equalTo(24)
        }

        mainImageView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.leading.trailing.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(18)
        }

        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(mainImageView.snp.bottom).offset(0)
            make.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(imageName: String, label: String) {
        if imageName != "" {
            if let image = UIImage(named: imageName) {
                mainImageView.image = image
                uncheckedImageView.image = UIImage(named: "ic_uncheckedBox")
                titleLabel.text = label
            }
        }
    }
}
