
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
    private static var savedUseFixedStep: Bool = false
    private static var savedStepLength: Double = 0.55
    private static var savedReqTime: Double = 20
    
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    
    private static let coordCacheKey = "CoordCache"
    private static let stepCacheKey = "StepCache"
    private static let reqTimeCacheKey = "ReqTimeCache"
    static let defaultXYH: [Double] = [5, 5, 90]
    static let defaultReqTime: Double = 20
    
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
    
    private var stepView: UIView = {
        let view = UIView()
        view.alpha = 0.8
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let stepStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let fixedStepSetStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let fixedStepSetLabel: UILabel = {
        let label = UILabel()
        label.text = "Fix Step Length"
        label.font = UIFont.pretendardBold(size: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var fixedStepSetSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.isOn = false
        toggleSwitch.addTarget(self, action: #selector(fixedStepSwitchToggled(_:)), for: .valueChanged)
        return toggleSwitch
    }()

    
    private let fixedStepLengthStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let fixedStepLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Step Length"
        label.font = UIFont.pretendardBold(size: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var fixedStepLengthTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "Value")
        textField.isEnabled = false
        return textField
    }()
    
    private let reqTimeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let reqTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Re-on Time"
        label.font = UIFont.pretendardBold(size: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var reqTimeTextField: UITextField = {
        let textField = createStyledTextField(placeholder: "Value")
        textField.isEnabled = true
        return textField
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
            make.height.equalTo(200)
        }
        
        contentView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        contentView.addSubview(reqTimeStackView)
        reqTimeStackView.snp.makeConstraints { make in
            make.bottom.equalTo(buttonStackView.snp.top).inset(-10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        reqTimeStackView.addArrangedSubview(reqTimeLabel)
        reqTimeStackView.addArrangedSubview(reqTimeTextField)
        
        contentView.addSubview(stepView)
        stepView.snp.makeConstraints { make in
            make.bottom.equalTo(reqTimeStackView.snp.top).inset(-10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(60)
        }
        stepView.addSubview(stepStackView)
        stepStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        fixedStepSetStackView.addArrangedSubview(fixedStepSetLabel)
        fixedStepSetStackView.addArrangedSubview(fixedStepSetSwitch)
        fixedStepSetSwitch.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
        }
        stepStackView.addArrangedSubview(fixedStepSetStackView)
        
        fixedStepLengthStackView.addArrangedSubview(fixedStepLengthLabel)
        fixedStepLengthStackView.addArrangedSubview(fixedStepLengthTextField)
        stepStackView.addArrangedSubview(fixedStepLengthStackView)
        
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(cancelButton)
        
        // Add stackViewForBirth
        contentView.addSubview(coordInfoStackView)
        coordInfoStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalTo(stepView.snp.top).inset(-10)
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
        fixedStepLengthTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        reqTimeTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    
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
            } else if textField == self.fixedStepLengthTextField {
                CoordSettingView.savedStepLength = Double(textField.text ?? "") ?? 0
            } else if textField == self.reqTimeTextField {
                CoordSettingView.savedReqTime = Double(textField.text ?? "") ?? 0
            }
        }
    }
    
    // MARK: - Apply Saved Values
    private func applySavedValues() {
        xTextField.text = String(CoordSettingView.savedStartX)
        yTextField.text = String(CoordSettingView.savedStartY)
        headingTextField.text = String(CoordSettingView.savedHeading)
        reqTimeTextField.text = String(CoordSettingView.savedReqTime)
    }
    
    private func applyCachedValues() {
        let cachedValues = CoordSettingView.loadCoordFromCache()
        xTextField.text = String(cachedValues.x)
        yTextField.text = String(cachedValues.y)
        headingTextField.text = String(cachedValues.heading)
        
        let cachedStepValues = CoordSettingView.loadStepInfoFromCache()
        fixedStepSetSwitch.isOn = cachedStepValues.isUseFixedStep
        fixedStepLengthTextField.text = String(cachedStepValues.stepLength)
        fixedStepLengthTextField.isEnabled = cachedStepValues.isUseFixedStep
        
        let cachedReqTime = CoordSettingView.loadEslReOnTimeFromCache()
        reqTimeTextField.text = String(cachedReqTime)
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
        
        let isUseFixedStep = fixedStepSetSwitch.isOn
        let stepLength = Double(fixedStepLengthTextField.text ?? "") ?? 0
        CoordSettingView.saveStepInfoToCache(isUseFixedStep: isUseFixedStep, stepLength: stepLength)
        
        
        let reqTime = Double(reqTimeTextField.text ?? "") ?? 0
        CoordSettingView.saveEslReOnTimeToCache(reqTime: reqTime)
        
        onSave?()
    }
    
    static func saveStepInfoToCache(isUseFixedStep: Bool, stepLength: Double) {
        let stepInfo = ["isUseFixedStep": isUseFixedStep, "stepLength": stepLength] as [String : Any]
        UserDefaults.standard.set(stepInfo, forKey: stepCacheKey)
    }

    static func loadStepInfoFromCache() -> (isUseFixedStep: Bool, stepLength: Double) {
        guard let stepInfo = UserDefaults.standard.dictionary(forKey: stepCacheKey) as? [String: Any],
              let isUseFixedStep = stepInfo["isUseFixedStep"] as? Bool,
              let stepLength = stepInfo["stepLength"] as? Double else {
            return (false, 0)
        }
        return (isUseFixedStep, stepLength)
    }
    
    static func saveEslReOnTimeToCache(reqTime: Double) {
        let cache = reqTime
        UserDefaults.standard.set(cache, forKey: reqTimeCacheKey)
        print("(CoordSettingView) : save ESL Re-on Time \(cache)")
    }

    static func loadEslReOnTimeFromCache() -> Double {
        guard let loadedReqTime = UserDefaults.standard.double(forKey: reqTimeCacheKey) as? Double else {
            print("(CoordSettingView) : load ESL Re-on Time \(defaultReqTime) // default")
            return defaultReqTime
        }
        print("(CoordSettingView) : load ESL Re-on Time \(loadedReqTime) // loaded")
        return loadedReqTime
    }
    
    static func saveCoordToCache(x: Double, y: Double, heading: Double) {
        let cache = ["x": x, "y": y, "heading": heading]
        UserDefaults.standard.set(cache, forKey: coordCacheKey)
    }
        
    static func loadCoordFromCache() -> (x: Double, y: Double, heading: Double) {
        guard let cache = UserDefaults.standard.dictionary(forKey: coordCacheKey) as? [String: Double] else {
            return (x: defaultXYH[0], y: defaultXYH[1], heading: defaultXYH[2])
        }
        return (x: cache["x"] ?? defaultXYH[0], y: cache["y"] ?? defaultXYH[1], heading: cache["heading"] ?? defaultXYH[2])
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
    
    @objc private func fixedStepSwitchToggled(_ sender: UISwitch) {
        fixedStepLengthTextField.isEnabled = sender.isOn
        if !sender.isOn {
            fixedStepLengthTextField.isEnabled = false
        }
    }
}
