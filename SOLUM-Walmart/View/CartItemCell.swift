import UIKit
import SnapKit

class CartItemCell: UICollectionViewCell {
    private let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
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
    }
    
    func configure(data: Esl) {
    }
}
