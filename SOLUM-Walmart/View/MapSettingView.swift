
import Foundation
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol MapSettingViewDelegate: AnyObject {
    func sliderValueChanged(index: Int, value: Double)
}

class MapSettingView: UIView {
    weak var delegate: MapSettingViewDelegate?
    private var sliderReferences: [Int: UISlider] = [:]
    
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    var onReset: (() -> Void)?
    
    var scales: [Double] = [0, 0, 0, 0]
    var SCALE_MIN_MAX: [Float] = [-50, 50]
    var OFFSET_MIN_MAX: [Float] = [-50, 50]
    
    private lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
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
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.pretendardBold(size: 16)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupActions()
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
            make.height.equalTo(400)
        }
        
        contentView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(resetButton)
        buttonStackView.addArrangedSubview(cancelButton)
        
//        contentView.addSubview(confirmButton)
//        confirmButton.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().offset(-10)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalTo(contentView.snp.centerX).offset(-10)
//            make.height.equalTo(30)
//        }
//        
//        contentView.addSubview(cancelButton)
//        cancelButton.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().offset(-10)
//            make.leading.equalTo(contentView.snp.centerX).offset(10)
//            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(30)
//        }
        
        // Main Vertical Stack View
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.spacing = 10
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
        ])
        
        let labels = ["x scale: ", "y scale: ", "x offset: ", "y offset: "]
        var valueStep: Float = 1.0
        
        for (index, labelText) in labels.enumerated() {
            let subVerticalStackView = UIStackView()
            subVerticalStackView.axis = .vertical
            subVerticalStackView.distribution = .fillEqually
            subVerticalStackView.spacing = 10
            subVerticalStackView.translatesAutoresizingMaskIntoConstraints = false

            let horizontalStackViewA = UIStackView()
            horizontalStackViewA.axis = .horizontal
            horizontalStackViewA.distribution = .fill
            horizontalStackViewA.spacing = 10
            horizontalStackViewA.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = labelText
            label.textAlignment = .left
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            let slider = UISlider()
            slider.minimumValue = (index < 2) ? SCALE_MIN_MAX[0] : OFFSET_MIN_MAX[0]
            slider.maximumValue = (index < 2) ? SCALE_MIN_MAX[1] : OFFSET_MIN_MAX[1]
            slider.value = Float(scales[index])
            slider.tag = index
            slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            
            sliderReferences[index] = slider
            
            let valueLabel = UILabel()
            valueLabel.text = String(format: "%.2f", scales[index])
            valueLabel.textAlignment = .right
            valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            valueLabel.tag = 1000 + index

            horizontalStackViewA.addArrangedSubview(label)
            horizontalStackViewA.addArrangedSubview(slider)
            horizontalStackViewA.addArrangedSubview(valueLabel)

            let horizontalStackViewB = UIStackView()
            horizontalStackViewB.axis = .horizontal
            horizontalStackViewB.distribution = .fillEqually
            horizontalStackViewB.spacing = 10
            horizontalStackViewB.translatesAutoresizingMaskIntoConstraints = false

            let buttonValues = ["0.1", "1", "10", "+", "-"]
            var selectedValueStepButton: UIButton?

            for buttonTitle in buttonValues {
                let button = UIButton()
                button.setTitle(buttonTitle, for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .lightGray
                button.layer.cornerRadius = 5

                if buttonTitle == "1" {
                    button.backgroundColor = SOLUM_COLOR
                    button.setTitleColor(.white, for: .normal)
                    selectedValueStepButton = button
                    valueStep = 1.0
                }

                // Assign unique tags
                if buttonTitle == "+" || buttonTitle == "-" {
                    button.tag = index + 100 // Offset for "+"/"-" buttons
                } else {
                    button.tag = index + 200 // Offset for "0.1", "1", "10" buttons
                }

                button.addAction(UIAction { [weak self, weak button] _ in
                    guard let self = self, let button = button else { return }
                    if buttonTitle == "0.1" || buttonTitle == "1" || buttonTitle == "10" {
                        valueStep = Float(buttonTitle) ?? 1.0

                        if let selectedButton = selectedValueStepButton {
                            selectedButton.backgroundColor = .lightGray
                            selectedButton.setTitleColor(.black, for: .normal)
                        }

                        button.backgroundColor = SOLUM_COLOR
                        button.setTitleColor(.white, for: .normal)
                        selectedValueStepButton = button
                    } else if buttonTitle == "+" || buttonTitle == "-" {
                        // Adjust slider value for + or -
                        if let slider = sliderReferences[index] {
                            let adjustment = (buttonTitle == "+") ? valueStep : -valueStep
                            let newValue = Float(slider.value) + adjustment

                            // Clamp newValue within the slider's min/max range
                            slider.value = max(slider.minimumValue, min(slider.maximumValue, newValue))

                            print("Slider tag: \(slider.tag), Value before: \(slider.value - adjustment), Adjustment: \(adjustment), New value: \(slider.value)")

                            // Update scales array and UI
                            let sliderValue = Double(slider.value)
                            self.scales[index] = sliderValue
                            if let valueLabel = self.contentView.viewWithTag(1000 + index) as? UILabel {
                                valueLabel.text = String(format: "%.2f", sliderValue)
                            }

                            // Notify delegate
                            self.delegate?.sliderValueChanged(index: index, value: sliderValue)
                        } else {
                            print("No slider found with index: \(index)")
                        }
                    }
                }, for: .touchUpInside)

                horizontalStackViewB.addArrangedSubview(button)
            }

            subVerticalStackView.addArrangedSubview(horizontalStackViewA)
            subVerticalStackView.addArrangedSubview(horizontalStackViewB)

            verticalStackView.addArrangedSubview(subVerticalStackView)
        }


        
//        for (index, labelText) in labels.enumerated() {
//            print("index = \(index) , labelText = \(labelText)")
//            let subVerticalStackView = UIStackView()
//            subVerticalStackView.axis = .vertical
//            subVerticalStackView.distribution = .fillEqually
//            subVerticalStackView.spacing = 10
//            subVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
//            
//            let horizontalStackViewA = UIStackView()
//            horizontalStackViewA.axis = .horizontal
//            horizontalStackViewA.distribution = .fill
//            horizontalStackViewA.spacing = 10
//            horizontalStackViewA.translatesAutoresizingMaskIntoConstraints = false
//            
//            let label = UILabel()
//            label.text = labelText
//            label.textAlignment = .left
//            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//            
//            let slider = UISlider()
//            if index < 2 {
//                slider.minimumValue = SCALE_MIN_MAX[0]
//                slider.maximumValue = SCALE_MIN_MAX[1]
//            } else {
//                slider.minimumValue = OFFSET_MIN_MAX[0]
//                slider.maximumValue = OFFSET_MIN_MAX[1]
//            }
//            slider.value = Float(scales[index])
//            slider.tag = index
//            print("index = \(index) , slider.tag = \(slider.tag)")
//            slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
//            
//            let valueLabel = UILabel()
//            valueLabel.text = String(format: "%.2f", scales[index])
//            valueLabel.textAlignment = .right
//            valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//            valueLabel.tag = 1000 + index
//            
//            horizontalStackViewA.addArrangedSubview(label)
//            horizontalStackViewA.addArrangedSubview(slider)
//            horizontalStackViewA.addArrangedSubview(valueLabel)
//            
//            let horizontalStackViewB = UIStackView()
//            horizontalStackViewB.axis = .horizontal
//            horizontalStackViewB.distribution = .fillEqually
//            horizontalStackViewB.spacing = 10
//            horizontalStackViewB.translatesAutoresizingMaskIntoConstraints = false
//            
//            let buttonValues = ["0.1", "1", "10", "+", "-"]
//            var selectedValueStepButton: UIButton?
//            
//            for buttonTitle in buttonValues {
//                let button = UIButton()
//                button.setTitle(buttonTitle, for: .normal)
//                button.setTitleColor(.black, for: .normal)
//                button.backgroundColor = .lightGray
//                button.layer.cornerRadius = 5
//                button.tag = index
//                print("index = \(index) , button.tag = \(button.tag)")
//                if buttonTitle == "1" {
//                    button.backgroundColor = SOLUM_COLOR
//                    button.setTitleColor(.white, for: .normal)
//                    selectedValueStepButton = button
//                    valueStep = 1.0
//                }
//
//                button.addAction(UIAction { [weak self, weak button] _ in
//                    guard let self = self, let button = button else { return }
//                    if buttonTitle == "0.1" || buttonTitle == "1" || buttonTitle == "10" {
//                        valueStep = Float(buttonTitle) ?? 1.0
//
//                        if let selectedButton = selectedValueStepButton {
//                            selectedButton.backgroundColor = .lightGray
//                            selectedButton.setTitleColor(.black, for: .normal)
//                        }
//
//                        button.backgroundColor = SOLUM_COLOR
//                        button.setTitleColor(.white, for: .normal)
//                        selectedValueStepButton = button
//                    } else if buttonTitle == "+" || buttonTitle == "-" {
//                        // Adjust slider value for + or -
//                        if let slider = self.contentView.viewWithTag(index) as? UISlider {
//                            
//                            let adjustment = (buttonTitle == "+") ? valueStep : -valueStep
//                            let newValue = Float(slider.value) + adjustment
//
//                            // Clamp newValue within the slider's min/max range
//                            slider.value = max(slider.minimumValue, min(slider.maximumValue, newValue))
//                            
//                            print("Slider current value: \(slider.value), adjustment: \(adjustment)")
//                            // Update scales array and UI
//                            let sliderValue = Double(slider.value)
//                            self.scales[index] = sliderValue
//                            if let valueLabel = self.contentView.viewWithTag(1000 + index) as? UILabel {
//                                valueLabel.text = String(format: "%.2f", sliderValue)
//                            }
//
//                            // Notify delegate
//                            self.delegate?.sliderValueChanged(index: index, value: sliderValue)
//                        } else {
//                            print("No slider found with tag : buttonTag = \(button.tag)")
//                        }
//                    }
//                }, for: .touchUpInside)
//
//                horizontalStackViewB.addArrangedSubview(button)
//            }
//
//            subVerticalStackView.addArrangedSubview(horizontalStackViewA)
//            subVerticalStackView.addArrangedSubview(horizontalStackViewB)
//
//            verticalStackView.addArrangedSubview(subVerticalStackView)
//        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        print("Button \(sender.title(for: .normal) ?? "") tapped.")
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let index = sender.tag
        let sliderValue = Double(sender.value)
        scales[index] = Double(sender.value)
        if let valueLabel = contentView.viewWithTag(1000 + index) as? UILabel {
            valueLabel.text = String(format: "%.2f", scales[index])
        }
        delegate?.sliderValueChanged(index: index, value: sliderValue)
//        mapView.updateMapAndPpScaleValues(index: index, value: sliderValue)
    }
    
    private func setupActions() {
        
    }
    
    @objc private func dismissDialog() {
        onCancel?()
        removeFromSuperview()
    }
    
    @objc private func saveTapped() {
        onSave?()
    }
    
    @objc private func resetTapped() {
        onReset?()
        removeFromSuperview()
    }
    
    func configure(with scales: [Double]) {
        self.scales = scales
        print(getLocalTimeString() + " , (FindProductView) configure = \(self.scales)")
        for (index, value) in scales.enumerated() {
            print(getLocalTimeString() + " , (FindProductView) : configure index = \(index)")
            if let slider = sliderReferences[index] {
                print(getLocalTimeString() + " , (FindProductView) : Updated slider \(index) to value \(slider.value)")
                slider.value = Float(value)
            } else {
                print("No slider reference found for index \(index)")
            }


            let valueLabelTag = 1000 + index
            if let valueLabel = contentView.viewWithTag(valueLabelTag) as? UILabel {
                valueLabel.text = String(format: "%.2f", value)
            }
        }
    }
}
