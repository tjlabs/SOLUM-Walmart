import UIKit
import SnapKit

class CartView: UIView {
    private let backgroundView = BackgroundView()
    private let headerView = HeaderView(title: "Cart")
    
    // Done Button
    var onFindProductImageViewTapped: (() -> Void)?
    private let findProductImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_findProduct")
        $0.isUserInteractionEnabled = true
    }
    
    private let deleteLabel = UILabel().then {
        $0.font = UIFont.pretendardRegular(size: 16)
        $0.textAlignment = .right
        $0.text = "Delete"
        $0.textColor = .white
    }
    
    private let selectedItemLabel = UILabel().then {
        $0.font = UIFont.pretendardRegular(size: 16)
        $0.textAlignment = .left
        $0.text = "Selected 4 items"
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
        bindActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.height.equalTo(64)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
        }
        
        addSubview(deleteLabel)
        deleteLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(80)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(headerView.snp.bottom).offset(0)
        }
        
        addSubview(selectedItemLabel)
        selectedItemLabel.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.width.equalTo(80)
            make.leading.equalToSuperview().inset(12)
            make.top.equalTo(headerView.snp.bottom).offset(0)
        }
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            print("Back button tapped in CartView")
            // Add more behavior as needed, e.g., callback to a parent view or controller
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(findProductImageViewTapped))
        findProductImageView.addGestureRecognizer(tapGesture)
    }
        
    @objc private func findProductImageViewTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.findProductImageView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) // Shrink to 90%
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.findProductImageView.transform = .identity // Reset to original scale
            }
        })
        
        onFindProductImageViewTapped?()
    }
}
