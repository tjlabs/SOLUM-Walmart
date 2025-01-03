import UIKit
import SnapKit

class PersonalOptionView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static var selectedLabels: [String] = []
    
    var onBackTapped: (() -> Void)?
    var onSearchTapped: (() -> Void)?
    var onCartTappedInPersonalOptionView: (() -> Void)?
    var onPersonTapped: (() -> Void)?
    var onMenuTapped: (() -> Void)?
    
    private let backgroundView = BackgroundView()
    
    private let headerView = HeaderView(title: "Personal Option")
    private let solumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "ic_solum_logo_opacity")
        return imageView
    }()
    
    var onRefreshLabelTapped: (() -> Void)?
    private let refreshLabel = UILabel().then {
        $0.font = UIFont.pretendardRegular(size: 16)
        $0.textAlignment = .right
        $0.text = "Refresh"
        $0.textColor = .white
        $0.isUserInteractionEnabled = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D9D9D9").withAlphaComponent(0.5)

        view.borderColor = UIColor(hex: "#FFFFFF")
        view.borderWidth = 1.0
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: "OptionCell")
        return collectionView
    }()
    
    // Done Button
    var onDoneImageViewTapped: (() -> Void)?
    private let doneImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_done")
        $0.isUserInteractionEnabled = true
    }
    var isDoneTapped: Bool = false
    
    let cellItemImageNames = ["vegan", "gluten", "allergent", "soy",
                              "sugar", "preservatives", "wheat", "corn",
                              "gmo", "milk", "colours", "probiotics",
                              "containstaurine", "hypoallergenic", "vitamins", "proteins",
                              "highfiber", "lowcalories"]
    
    let cellItemLabelNames = ["Vegan", "Gluten Free", "No Allergent", "No Soy",
                              "Sugar Free", "No Preservatives", "No Wheat", "No Corn",
                              "No GMO", "Lactose Free", "No Artificial Colours", "Contains Probiotics",
                              "Contains Taurine", "Hypo Allergenic", "Natural Vitamins", "High Quality Proteins",
                              "High Fiber", "Low Calories"]
    
    let defaultCellItemLabelNames = ["Vegan", "Gluten Free", "Lactose Free", "Sugar Free"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
        bindActions()
        verifyToken()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func verifyToken() {
        let tokenInput = TOKEN_INPUT(username: TokenInfo.username, password: TokenInfo.password)
        NetworkManager.shared.postToken(url: SOLUM_TOKEN_URL, input: tokenInput, completion: { [self] statusCode, returnedString in
            if statusCode == 200 {
                parseAndSetToken(from: returnedString)
            }
        })
    }
    
    func parseAndSetToken(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to Data.")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(ApiResponse.self, from: jsonData)
            let accessToken = apiResponse.responseMessage.access_token
            TokenInfo.setToken(token: accessToken)
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    private func setupLayout() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.height.equalTo(64)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
        }
        
        addSubview(solumImageView)
        solumImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.left.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        addSubview(refreshLabel)
        refreshLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(100)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(headerView.snp.bottom).offset(0)
        }
        
        addSubview(doneImageView)
        doneImageView.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            make.left.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(refreshLabel.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(doneImageView.snp.top).offset(-10)
        }
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(1)
            make.leading.trailing.equalToSuperview().inset(1)
            make.bottom.equalTo(containerView.snp.bottom).inset(30)
        }
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            self?.onBackTapped?()
        }
        
        headerView.onSearchImageViewTapped = { [weak self] in
            self?.onSearchTapped?()
        }
        
        headerView.onCartImageViewTapped = {
            if self.isDoneTapped {
                self.onCartTappedInPersonalOptionView?()
            } else {
                self.showDialogView()
            }
        }
        
        headerView.onPersonImageViewTapped = { [weak self] in
            self?.onPersonTapped?()
        }
        
        headerView.onMenuImageViewTapped = { [weak self] in
            self?.onMenuTapped?()
        }
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doneImageViewTapped))
        doneImageView.addGestureRecognizer(tapGesture)
        
        let refreshTapGesture = UITapGestureRecognizer(target: self, action: #selector(refreshLabelTapped))
        refreshLabel.addGestureRecognizer(refreshTapGesture)
    }
    
    @objc private func doneImageViewTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.doneImageView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.doneImageView.transform = .identity
            }
        })
        
        if isDoneTapped {
            isDoneTapped = false
            collectionView.isUserInteractionEnabled = true
            doneImageView.image = UIImage(named: "ic_done")
        } else {
            isDoneTapped = true
            collectionView.isUserInteractionEnabled = false
            doneImageView.image = UIImage(named: "ic_done_disable")
            
            PersonalOptionView.selectedLabels = getSelectedLabels()
        }
        
        onDoneImageViewTapped?()
    }
    
    private func showDialogView() {
        print("(PersonalOptionView) Check-out Button tapped")
        
        let dialogView = DialogView()
        dialogView.onConfirm = { [weak self] in
            print("Confirmed checkout")
        }
        
        if let parentView = self.superview {
            parentView.addSubview(dialogView)
            dialogView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func getSelectedLabels() -> [String] {
        guard let visibleCells = collectionView.visibleCells as? [OptionCell] else { return [] }
        return visibleCells.compactMap { $0.isSelectedState ? $0.labelText : nil }
    }
    
    @objc private func refreshLabelTapped() {
        guard let visibleCells = collectionView.visibleCells as? [OptionCell] else { return }
        for cell in visibleCells {
            cell.deselect()
        }
    }
}

extension PersonalOptionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionCell", for: indexPath) as! OptionCell
        let index = indexPath.item
        var imageName = ""
        var labelText = ""
        
        if index < cellItemImageNames.count {
            imageName = "ic_option_\(index+1)_\(cellItemImageNames[index])"
            labelText = cellItemLabelNames[index]
        }
        
        cell.configure(imageName: imageName, label: labelText)

        if defaultCellItemLabelNames.contains(labelText) {
            cell.isSelectedState = true
            cell.uncheckedImageView.image = UIImage(named: "ic_checkbox_GREEN")
            PersonalOptionView.selectedLabels.append(labelText)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/4
        let height = collectionView.frame.height/5
        return CGSize(width: width, height: height)
    }
}
