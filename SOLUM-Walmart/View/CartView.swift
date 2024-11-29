import UIKit
import SnapKit

class CartView: UIView {
    private let backgroundView = BackgroundView()
    private let headerView = HeaderView(title: "Cart")
    
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
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            print("Back button tapped in CartView")
            // Add more behavior as needed, e.g., callback to a parent view or controller
        }
    }
}
