import UIKit
import SnapKit

class PersonalOptionView: UIView {
    private let backgroundView = BackgroundView()
    private let headerView = HeaderView(title: "Personal Option")
    private let solumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ic_solum_logo")
        return imageView
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = SOLUM_COLOR
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
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
        
        addSubview(solumImageView)
        solumImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.left.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            print("Back button tapped in PersonalOptionView")
            // Add more behavior as needed, e.g., callback to a parent view or controller
        }
    }
}
