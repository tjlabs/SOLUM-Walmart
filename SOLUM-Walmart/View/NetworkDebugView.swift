import UIKit
import SnapKit

class NetworkDebugView: UIView {
    var onBack: (() -> Void)?

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.pretendardBold(size: 16)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dismissDialog), for: .touchUpInside)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        return scrollView
    }()
    
    private let networkDebugLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.pretendardBold(size: 8)
        label.textAlignment = .left
        label.numberOfLines = 0 // Allow multiple lines
        label.isUserInteractionEnabled = true // Enable user interaction for gesture recognition
        return label
    }()
    
    init(debugString: String) {
        super.init(frame: .zero)
        setupLayout()
        setupActions()
        configure(debugString: debugString)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(100)
        }
        
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(cancelButton.snp.top).offset(-10)
        }
        
        scrollView.addSubview(networkDebugLabel)
        networkDebugLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalTo(scrollView.snp.width) // Ensure label width matches the scroll view width
        }
    }
    
    private func setupActions() {
        // Add long press gesture to the label
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(copyLabelText(_:)))
        networkDebugLabel.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func dismissDialog() {
        onBack?()
        removeFromSuperview()
    }
    
    func configure(debugString: String) {
        // Set the text for the debug label
        networkDebugLabel.text = debugString
        
        // Update the scroll view's content size dynamically
        DispatchQueue.main.async {
            self.networkDebugLabel.sizeToFit()
            self.scrollView.contentSize = self.networkDebugLabel.frame.size
        }
    }
    
    @objc private func copyLabelText(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return } // Trigger on long press begin
        guard let text = networkDebugLabel.text else { return }
        
        UIPasteboard.general.string = text
        
        // Optional: Show a toast or feedback to the user
        let alert = UIAlertController(title: "Copied", message: "Debug text copied to clipboard.", preferredStyle: .alert)
        if let parentViewController = self.getParentViewController() {
            parentViewController.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true)
            }
        }
    }
    
    private func getParentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            parentResponder = responder.next
        }
        return nil
    }
}
