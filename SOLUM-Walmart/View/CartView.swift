import UIKit
import RxSwift
import RxCocoa
import SnapKit

class CartView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onBackTappedInCartView: (() -> Void)?
//    var onSearchTapped: (() -> Void)?
    var onPersonTappedInCartView: (() -> Void)?
//    var onMenuTapped: (() -> Void)?
    
    private let backgroundView = BackgroundView()
    private let headerView = HeaderView(title: "Cart")
    var cartItems = [Esl]()
    
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
    
    private let selectedItemSmallLabel = UILabel().then {
        $0.font = UIFont.pretendardRegular(size: 12)
        $0.textAlignment = .left
        $0.text = "Selected 4 items"
        $0.textColor = .white
    }
    
    private let subtotalLabel = UILabel().then {
        $0.font = UIFont.pretendardRegular(size: 12)
        $0.textAlignment = .left
        $0.text = "Subtotal"
        $0.textColor = .white
    }
    
    private let priceLabel = UILabel().then {
        $0.font = UIFont.pretendardSemiBold(size: 20)
        $0.textAlignment = .right
        $0.text = "$ 100.11"
        $0.textColor = .white
    }
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        view.alpha = 0.2
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CartItemCell.self, forCellWithReuseIdentifier: "CartItemCell")
        return collectionView
    }()
    
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
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(headerView.snp.bottom).offset(0)
        }
        
        addSubview(selectedItemLabel)
        selectedItemLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(120)
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(headerView.snp.bottom).offset(0)
        }
        
        addSubview(findProductImageView)
        findProductImageView.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            make.left.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        addSubview(subtotalLabel)
        subtotalLabel.snp.makeConstraints { make in
            make.bottom.equalTo(findProductImageView.snp.top).offset(-15)
            make.left.equalToSuperview().inset(20)
            make.width.equalTo(100)
        }
        
        addSubview(selectedItemSmallLabel)
        selectedItemSmallLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subtotalLabel.snp.top).offset(-10)
            make.left.equalToSuperview().inset(20)
            make.width.equalTo(150)
        }
        
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.bottom.equalTo(findProductImageView.snp.top).offset(-15)
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(150)
        }
        
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.bottom.equalTo(selectedItemSmallLabel.snp.top).offset(-10)
            make.height.equalTo(1)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            self?.onBackTappedInCartView?()
        }
        
        headerView.onPersonImageViewTapped = {[weak self] in
            print("person button tapped in CartView")
            self?.onPersonTappedInCartView?()
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
    
    func updateProducts(_ outputESL: OutputEsl) {
        let esl_list = outputESL.esl_list
        for item in esl_list {
            for esl in item.esls {
                if cartItems.count < 5 {
                    cartItems.append(esl)
                }
            }
        }
    }
}

extension CartView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartItemCell", for: indexPath) as! CartItemCell
        let index = indexPath.item

        cell.configure(data: cartItems[index])
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height/4
        return CGSize(width: width, height: height)
    }
}
