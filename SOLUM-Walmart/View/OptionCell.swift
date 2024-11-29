import UIKit
import SnapKit

class OptionCell: UICollectionViewCell {
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
        mainImageView.contentMode = .scaleAspectFit
//        uncheckedImageView.contentMode = .scaleAspectFit
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        backgroundColor = UIColor(white: 1.0, alpha: 0.3) // 30% white alpha
        
        addSubview(mainImageView)
        addSubview(uncheckedImageView)
        addSubview(titleLabel)

//        uncheckedImageView.snp.makeConstraints { make in
//            make.top.leading.equalToSuperview().inset(5)
//            make.width.height.equalTo(10)
//        }

        mainImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.top.bottom.equalToSuperview()
//            make.leading.trailing.equalToSuperview().inset(10)
//            make.top.bottom.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(imageName: String?, label: String?) {
        print("imageName = \(imageName) // label = \(label)")
//        guard let imageName = imageName, let label = label, let image = UIImage(named: imageName) else {
//            isHidden = true
//            return
//        }
//        mainImageView.image = image
//        uncheckedImageView.image = UIImage(named: "ic_uncheckedBox")
//        titleLabel.text = label
        isHidden = false
    }
}
