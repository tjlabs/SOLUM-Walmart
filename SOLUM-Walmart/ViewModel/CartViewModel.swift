import Foundation
import RxSwift
import RxRelay

class CartViewModel {
    let allProductsData: BehaviorRelay<ShopOutput?> = BehaviorRelay(value: nil)
    
    private let disposeBag = DisposeBag()
    
    func fetchAllProductsa(input: Int) {
        NetworkManager.shared.getAllProducts(url: SHOP_PRODUCT_URL, input: input) { [weak self] statusCode, result in
            guard let self = self else { return }

            if statusCode == 200, let data = result.data(using: .utf8) {
                if let decodedResult = try? JSONDecoder().decode(ShopOutput.self, from: data) {
                    print("All Products Output : \(decodedResult)")
                    self.allProductsData.accept(decodedResult)
                } else {
                    print("Failed to fetch all prducts: \(result)")
                    self.allProductsData.accept(nil)
                }
            } else {
                print("Failed to fetch all prducts: \(result)")
                self.allProductsData.accept(nil)
            }
        }
    }
}
