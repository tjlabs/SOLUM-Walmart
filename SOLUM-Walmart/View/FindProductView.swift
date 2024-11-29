import UIKit
import SnapKit

class FindProductView: UIView {
    private let backgroundView = BackgroundView()
    private let headerView = HeaderView(title: "Find Product")
    
    var onAisleGuideImageViewTapped: (() -> Void)?
    private let aisleGuideImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_aisleGuide")
        $0.isUserInteractionEnabled = true
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
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            print("Back button tapped in FindProductView")
            // Add more behavior as needed, e.g., callback to a parent view or controller
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(aisleGuideImageViewTapped))
        aisleGuideImageView.addGestureRecognizer(tapGesture)
    }
        
    @objc private func aisleGuideImageViewTapped() {
        onAisleGuideImageViewTapped?()
    }
}