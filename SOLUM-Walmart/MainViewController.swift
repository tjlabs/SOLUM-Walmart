
import UIKit
import SnapKit

class MainViewController: UIViewController {
    let backgroundView = BackgroundView()
    let personalOptionView = PersonalOptionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
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
}

