
import Foundation
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then


class CoordSettingView: UIView {
    private let debounceInterval: TimeInterval = 0.2
    private var debounceTimer: Timer?
    
    let VIEW_BORDER_WIDTH: CGFloat = 2
    let VIEW_CORNER_RADIUS: CGFloat = 6
    
    private static var savedStartX: Double = 0
    private static var savedStartY: Double = 0
    private static var savedHeading: Double = 0
    
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    
    private static let coordCacheKey = "CoordCache"
    
    private lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.alpha = 0.8
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.pretendardBold(size: 16)
        button.backgroundColor = SOLUM_COLOR
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.pretendardBold(size: 16)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dismissDialog), for: .touchUpInside)
        return button
    }()
    
    private lazy var coordInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var xTextField = createStyledTextField(placeholder: "X")
    private lazy var yTextField = createStyledTextField(placeholder: "Y")
    private lazy var headingTextField = createStyledTextField(placeholder: "Heading")
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        applyCachedValues()
//        applySavedValues()
        addTouchHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    private func setupLayout() {
        addSubview(darkView)
        darkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
            
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(30)
            make.height.equalTo(100)
        }
        
        contentView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(cancelButton)
        
        // Add stackViewForBirth
        contentView.addSubview(coordInfoStackView)
        coordInfoStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalTo(buttonStackView.snp.top).inset(-10)
        }
        
        coordInfoStackView.addArrangedSubview(xTextField)
        coordInfoStackView.addArrangedSubview(yTextField)
        coordInfoStackView.addArrangedSubview(headingTextField)
    }
    
    // MARK: - Add Touch Handlers
    private func addTouchHandlers() {
        xTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        yTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        headingTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
//    @objc private func textFieldEditingChanged(_ textField: UITextField) {
//        if textField == xTextField {
//            CoordSettingView.savedStartX = Double(textField.text ?? "") ?? 0
//        } else if textField == yTextField {
//            CoordSettingView.savedStartY = Double(textField.text ?? "") ?? 0
//        } else if textField == headingTextField {
//            CoordSettingView.savedHeading = Double(textField.text ?? "") ?? 0
//        }
//    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        debounceTimer?.invalidate()

        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if textField == self.xTextField {
                CoordSettingView.savedStartX = Double(textField.text ?? "") ?? 0
            } else if textField == self.yTextField {
                CoordSettingView.savedStartY = Double(textField.text ?? "") ?? 0
            } else if textField == self.headingTextField {
                CoordSettingView.savedHeading = Double(textField.text ?? "") ?? 0
            }
        }
    }
    
    // MARK: - Apply Saved Values
    private func applySavedValues() {
        xTextField.text = String(CoordSettingView.savedStartX)
        yTextField.text = String(CoordSettingView.savedStartY)
        headingTextField.text = String(CoordSettingView.savedHeading)
    }
    
    private func applyCachedValues() {
        let cachedValues = CoordSettingView.loadCoordFromCache()
        xTextField.text = String(cachedValues.x)
        yTextField.text = String(cachedValues.y)
        headingTextField.text = String(cachedValues.heading)
    }
    
    @objc private func dismissDialog() {
        onCancel?()
        removeFromSuperview()
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }

    
    @objc private func saveTapped() {
        let x = Double(xTextField.text ?? "") ?? 0
        let y = Double(yTextField.text ?? "") ?? 0
        let heading = Double(headingTextField.text ?? "") ?? 0
        CoordSettingView.saveCoordToCache(x: x, y: y, heading: heading)
        onSave?()
    }
    
    static func saveCoordToCache(x: Double, y: Double, heading: Double) {
        let cache = ["x": x, "y": y, "heading": heading]
        UserDefaults.standard.set(cache, forKey: coordCacheKey)
    }
        
    static func loadCoordFromCache() -> (x: Double, y: Double, heading: Double) {
        guard let cache = UserDefaults.standard.dictionary(forKey: coordCacheKey) as? [String: Double] else {
            return (x: 0, y: 0, heading: 0)
        }
        return (x: cache["x"] ?? 0, y: cache["y"] ?? 0, heading: cache["heading"] ?? 0)
    }
    
    private func createStyledTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = UIFont.pretendardBold(size: 18)
        textField.textAlignment = .left
        textField.textColor = .black
        textField.layer.borderWidth = VIEW_BORDER_WIDTH
        textField.layer.cornerRadius = VIEW_CORNER_RADIUS
        textField.layer.borderColor = SOLUM_COLOR.cgColor
        textField.addLeftPadding()
        
        return textField
    }
}
