import UIKit
import SnapKit

class SplashViewController: UIViewController {
    
    let backgroundView = BackgroundView()
    private let solumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ic_solum_logo")
        return imageView
    }()
    
    func viewWillAppear() {
        super.viewWillAppear(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLaytout()
        moveToMain()
        
    }
    
    private func setupLaytout() {
        view.addSubview(backgroundView)
        view.addSubview(solumImageView)
        backgroundView.snp.makeConstraints { make in
            make.top.bottom.left.trailing.equalToSuperview()
        }
        
        solumImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.left.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
    }
    
    private func moveToMain() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            }, completion: { finished in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            })
        }
    }
}
