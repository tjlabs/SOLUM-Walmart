
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
    
    let sector_id: Int = 4
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchESLtData()
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
    
    private func fetchESLtData() {
        viewModel.fetchEslData(input: self.sector_id)
    }
    
    private func showCartView() {
        personalOptionView.isHidden = true
        let cartView = CartView()
        cartView.onBackTappedInCartView = { [self] in
            self.removeCurrentSubview(cartView)
            personalOptionView.isHidden = false
        }
        
        cartView.onFindProductImageViewTapped = { [self] in
            self.removeCurrentSubview(cartView)
            showFindProductView()
        }
        
        viewModel.eslData
            .subscribe(onNext: { [weak cartView] eslData in
                guard let eslData = eslData else { return }
                cartView?.updateProducts(eslData)
            })
            .disposed(by: disposeBag)
        moveToSubview(cartView)
    }
    
    private func showFindProductView() {
        let findProductView = FindProductView()
        findProductView.onBackTappedInFindProductView = { [self] in
            self.removeCurrentSubview(findProductView)
            personalOptionView.isHidden = false
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

