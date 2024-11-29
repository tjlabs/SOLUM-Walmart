import Foundation
import RxSwift
import RxRelay

class CartViewModel {
    // Observables for the data
    let eslData: BehaviorRelay<OutputEsl?> = BehaviorRelay(value: nil)
    
    private let disposeBag = DisposeBag()
    
    func fetchEslData(input: Int) {
        NetworkManager.shared.getESL(url: ESL_PRODUCT_URL, input: input) { [weak self] statusCode, result in
            guard let self = self else { return }

            if statusCode == 200, let data = result.data(using: .utf8) {
                if let decodedResult = try? JSONDecoder().decode(OutputEsl.self, from: data) {
                    print("ESL Output : \(decodedResult)")
                    self.eslData.accept(decodedResult)
                } else {
                    print("Failed to fetch ESL data: \(result)")
                    self.eslData.accept(nil)
                }
            } else {
                print("Failed to fetch ESL data: \(result)")
                self.eslData.accept(nil)
            }
        }
    }
}
