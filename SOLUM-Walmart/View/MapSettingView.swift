
import Foundation
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class MapSettingView: UIView {
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
    
    var scales: [Double] = [0, 0, 0, 0]
    let SCALE_MIN_MAX: [Float] = [-25, 25]
    let OFFSET_MIN_MAX: [Float] = [-25, 25]
    
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
        view.backgroundColor = .white
        view.alpha = 0.8
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.pretendardBold(size: 16)
        button.backgroundColor = SOLUM_COLOR
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
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
    
//    private func setupLayout() {
//        addSubview(darkView)
//        darkView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        
//        addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.width.equalToSuperview().inset(30)
//            make.height.equalTo(400)
//        }
//        
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
//        
//        // Setting View
//        let verticalStackView = UIStackView()
//        verticalStackView.axis = .vertical
//        verticalStackView.distribution = .fillEqually
//        verticalStackView.spacing = 10
//        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(verticalStackView)
//
//        NSLayoutConstraint.activate([
//            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
//        ])
//
//        let labels = ["x scale: ", "y scale: ", "x offset: ", "y offset: "]
//
//        for (index, labelText) in labels.enumerated() {
//            let horizontalStackView = UIStackView()
//            horizontalStackView.axis = .horizontal
//            horizontalStackView.distribution = .fill
//            horizontalStackView.spacing = 10
//            horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
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
//            
//            slider.value = Float(scales[index])
//            slider.tag = index
//            
//            slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
//            
//            let valueLabel = UILabel()
//            valueLabel.text = String(format: "%.2f", scales[index])
//            valueLabel.textAlignment = .right
//            valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//            valueLabel.tag = 1000 + index
//            
//            horizontalStackView.addArrangedSubview(label)
//            horizontalStackView.addArrangedSubview(slider)
//            horizontalStackView.addArrangedSubview(valueLabel)
//            
//            verticalStackView.addArrangedSubview(horizontalStackView)
//        }
//    }
    
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
        
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(contentView.snp.centerX).offset(-10)
            make.height.equalTo(30)
        }
        
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalTo(contentView.snp.centerX).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        
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
        var valueStep: Float = 1.0 // Default step value
        
        for (index, labelText) in labels.enumerated() {
            // Create a sub verticalStackView for this iteration
            let subVerticalStackView = UIStackView()
            subVerticalStackView.axis = .vertical
            subVerticalStackView.distribution = .fillEqually
            subVerticalStackView.spacing = 10
            subVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Horizontal Stack View A
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
            if index < 2 {
                slider.minimumValue = SCALE_MIN_MAX[0]
                slider.maximumValue = SCALE_MIN_MAX[1]
            } else {
                slider.minimumValue = OFFSET_MIN_MAX[0]
                slider.maximumValue = OFFSET_MIN_MAX[1]
            }
            slider.value = Float(scales[index])
            slider.tag = index
            slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            
            let valueLabel = UILabel()
            valueLabel.text = String(format: "%.2f", scales[index])
            valueLabel.textAlignment = .right
            valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            valueLabel.tag = 1000 + index
            
            horizontalStackViewA.addArrangedSubview(label)
            horizontalStackViewA.addArrangedSubview(slider)
            horizontalStackViewA.addArrangedSubview(valueLabel)
            
            // Horizontal Stack View B
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
                button.tag = index

                if buttonTitle == "1" {
                    button.backgroundColor = .blue
                    button.setTitleColor(.white, for: .normal)
                    selectedValueStepButton = button
                    valueStep = 1.0
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
                    }
                }, for: .touchUpInside)

                horizontalStackViewB.addArrangedSubview(button)
            }

            
            // Add A and B to the subVerticalStackView
            subVerticalStackView.addArrangedSubview(horizontalStackViewA)
            subVerticalStackView.addArrangedSubview(horizontalStackViewB)
            
            // Add the subVerticalStackView to the main verticalStackView
            verticalStackView.addArrangedSubview(subVerticalStackView)
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        print("Button \(sender.title(for: .normal) ?? "") tapped.")
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let valueLabelTag = 1000 + sender.tag
        if let valueLabel = viewWithTag(valueLabelTag) as? UILabel {
            valueLabel.text = String(format: "%.2f", sender.value)
        }
    }
    
    private func setupActions() {
        
    }
    
    @objc private func dismissDialog() {
        onCancel?()
        removeFromSuperview()
    }
    
    @objc private func confirmTapped() {
        onConfirm?()
        removeFromSuperview()
    }
}
