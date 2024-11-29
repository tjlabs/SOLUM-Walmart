
import Foundation
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class HeaderView: UIView {
    
    private var title: String?
    
    var onBackImageViewTapped: (() -> Void)?
    
    private let backImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_back")
        $0.isUserInteractionEnabled = true
    }
    
    private let searchImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_search")
    }
    
    private let cartImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        if let image = UIImage(named: "ic_cart") {
            $0.image = image.withAlignmentRectInsets(UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2))
        }
    }
    
    private let cartCountView: UIView = {
        let view = UIView()
        view.backgroundColor = SOLUM_COLOR
        view.layer.cornerRadius = 12.5
        view.isHidden = true
        return view
    }()
    
    private let cartCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.pretendardBold(size: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let personImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        if let image = UIImage(named: "ic_person") {
            $0.image = image.withAlignmentRectInsets(UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2))
        }
    }
    
    private let menuImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_menu")
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendardBold(size: 14)
        $0.textAlignment = .left
        $0.textColor = .white
    }
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        view.alpha = 0.2
        return view
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        self.title = title
        setupLayout(title: title)
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(title: String) {
        addSubview(backImageView)
        addSubview(titleLabel)
        
        addSubview(searchImageView)
        addSubview(cartImageView)
        addSubview(personImageView)
        addSubview(menuImageView)
        
        addSubview(separatorView)
        
        backImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
        }
        
        titleLabel.text = title
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(backImageView.snp.trailing).offset(12)
        }
        
        menuImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        
        personImageView.snp.makeConstraints { make in
            make.trailing.equalTo(menuImageView.snp.leading).offset(-12)
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        cartImageView.snp.makeConstraints { make in
            make.trailing.equalTo(personImageView.snp.leading).offset(-12)
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        searchImageView.snp.makeConstraints { make in
            make.trailing.equalTo(cartImageView.snp.leading).offset(-12)
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImageView.addGestureRecognizer(tapGesture)
    }
        
    @objc private func backImageViewTapped() {
        onBackImageViewTapped?()
    }
}


