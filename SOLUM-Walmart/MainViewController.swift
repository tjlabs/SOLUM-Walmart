
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainViewController: UIViewController {
    let backgroundView = BackgroundView()
    
    let personalOptionView = PersonalOptionView()
    
    private let disposeBag = DisposeBag()
    private let viewModel = CartViewModel()
    private var currentSubview: UIView?
    
    let sector_id: Int = 3
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllProducts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupActions()
    }
    
    private func setupLayout() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints{ make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(personalOptionView)
        personalOptionView.snp.makeConstraints{ make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupActions() {
        personalOptionView.onCartTappedInPersonalOptionView = { [weak self] in
            self?.handleCartTappedInPersonalOptionView()
        }
    }
    
    private func handleCartTappedInPersonalOptionView() {
        showCartView()
    }
    
    private func fetchAllProducts() {
        viewModel.fetchAllProductsa(input: self.sector_id)
    }
    
    private func showCartView() {
        personalOptionView.isHidden = true
        let cartView = CartView()
        cartView.onBackTappedInCartView = { [self] in
            self.removeCurrentSubview(cartView)
            personalOptionView.isHidden = false
        }
        
        cartView.onFindProductImageViewTapped = { [weak self] onCartProducts, offCartProducts in
            guard let self = self else { return }
            self.removeCurrentSubview(cartView)
            self.showFindProductView(onCartProducts: onCartProducts, offCartProducts: offCartProducts)
//            self.showFindProductView(with: sortedCartProducts)
        }
        
        viewModel.allProductsData
            .subscribe(onNext: { [weak cartView] allProducts in
                guard let allProducts = allProducts else { return }
                cartView?.updateAllProducts(outputProducts: allProducts)
            })
            .disposed(by: disposeBag)
        moveToSubview(cartView)
    }
    
//    private func showFindProductView(with sortedCartProducts: [Esl]) {
//        let findProductView = FindProductView()
//
//        findProductView.configure(with: sortedCartProducts)
//        
//        findProductView.onBackTappedInFindProductView = { [weak self] in
//            guard let self = self else { return }
//            self.removeCurrentSubview(findProductView)
//            self.personalOptionView.isHidden = false
//        }
//        
//        moveToSubview(findProductView)
//    }
    
    private func showFindProductView(onCartProducts: [ProductInfo], offCartProducts: [ProductInfo]) {
        let findProductView = FindProductView()
//        findProductView.configure(with: sortedCartProducts)
        findProductView.configure(onCartProducts: onCartProducts, offCartProducts: offCartProducts)
        findProductView.onBackTappedInFindProductView = { [weak self] in
            guard let self = self else { return }
            self.removeCurrentSubview(findProductView)
            self.personalOptionView.isHidden = false
        }
        
        moveToSubview(findProductView)
    }

    
    private func removeCurrentSubview(_ subview: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            subview.alpha = 0
            subview.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
        }, completion: { _ in
            subview.removeFromSuperview()
            if self.currentSubview === subview {
                self.currentSubview = nil
            }
        })
    }
    
    private func moveToSubview(_ subview: UIView) {
        if let existingSubview = currentSubview {
            removeCurrentSubview(existingSubview)
        }
        
        subview.frame = view.bounds
        subview.alpha = 0
        subview.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        
        view.addSubview(subview)
        currentSubview = subview
        
        UIView.animate(withDuration: 0.3, animations: {
            subview.alpha = 1
            subview.transform = .identity
        })
    }
}

