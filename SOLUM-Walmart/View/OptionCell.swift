import UIKit
import SnapKit

class OptionCell: UICollectionViewCell {
    private let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.3)
        view.borderColor = .systemGray4
        view.borderWidth = 1.2
        return view
    }()
        
    private let mainImageView = UIImageView()
    private let uncheckedImageView = UIImageView()
    private let titleLabel = UILabel()
    
    private var isSelectedState = false
    private let randomImages = [
        "ic_checkbox_RED", "ic_checkbox_GREEN", "ic_checkbox_YELLOW",
        "ic_checkbox_BLUE", "ic_checkbox_MAGENTA", "ic_checkbox_CYAN", "ic_checkbox_WHITE"
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
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
        titleLabel.font = UIFont.pretendardMedium(size: 8)
        
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
    
    @objc private func cellTapped() {
        guard let title = titleLabel.text, !title.isEmpty else {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        })
        isSelectedState.toggle()
        if isSelectedState {
            let randomImage = randomImages.randomElement() ?? "ic_checkbox_RED"
            uncheckedImageView.image = UIImage(named: randomImage)
        } else {
            uncheckedImageView.image = UIImage(named: "ic_uncheckedBox")
        }
    }

    func deselect() {
        if let title = titleLabel.text, !title.isEmpty {
            isSelectedState = false
            uncheckedImageView.image = UIImage(named: "ic_uncheckedBox")
        }
    }
}
