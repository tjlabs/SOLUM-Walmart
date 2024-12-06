import UIKit
import SnapKit
import Kingfisher
import OlympusSDK

class FindProductView: UIView, Observer, MapSettingViewDelegate, MapViewForScaleDelegate {
    func mapScaleUpdated() {
        plotOnCartProducts(products: self.onCartProducts)
    }
    
    func sliderValueChanged(index: Int, value: Double) {
        mapView.updateMapAndPpScaleValues(index: index, value: value)
    }
    
    func update(result: OlympusSDK.FineLocationTrackingResult) {
        let currentIndex = result.index
        if currentIndex > preIndex {
            mapView.updateResultInMap(result: result)
            let userCoord = [result.x, result.y, result.absolute_heading]
            let nearbyCategories = checkNearbyCategories(user: userCoord)
            
            for nearbyCategory in nearbyCategories {
                let validESLs = checkMatchingProducts(categoryInfo: nearbyCategory)
                if !validESLs.0.isEmpty {
                    print("(FindProductView) : ESL for LED")
                    for item in validESLs.0 {
                        print("(FindProductView) : ESL ID = \(item.id)")
                        print("(FindProductView) : ESL Color = \(item.led_color)")
                    }
                }
//                activateValidESLs(validESLs: validESLs.0)
                
                
                let validProducts = checkMatchingProductForContents(categoryInfo: nearbyCategory, user: userCoord)
                for product in validProducts {
                    let contents = makeProductContents(user: userCoord, product: product)
                    let contentsUI = makeContentsUI(product: product)
                    showNearbyProduct(categoryUI: contentsUI, title: product.product_name, contents: contents)
                }
            }
        }
        preIndex = currentIndex
    }
    
    func report(flag: Int) { }

    private var onCartProducts = [ProductInfo]()
    private var offCartProducts = [ProductInfo]()
    private var categoryDrawed = [Int]()
    private var categoryList = Set<CategoryInfo>()
    private var personalProfile = [String]()
    private let defaultColor = "WHITE"
    private let profileColorDict: [String: String] = ["Vegan":"GREEN", "Gluten Free":"RED", "Lactose Free":"BLUE", "Sugar Free":"MAGENTA"]
    var eslDict = [String: Double]()
    var productDict = [String: Double]()
    let REQ_DISTANCE: Double = 2.0
    let REQ_LED_TIME: Double = 20*1000
    
    private let backgroundView = BackgroundView()
    private let headerView = HeaderView(title: "Find Product")
    
    var onBackTappedInFindProductView: (() -> Void)?
    var onAisleGuideImageViewTapped: (() -> Void)?
    private let aisleGuideImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_aisleGuide")
        $0.isUserInteractionEnabled = true
    }
    
    var onRefreshLabelTapped: (() -> Void)?
    
    private var isServiceStarted: Bool = false
    var preIndex: Int = -1
    
    // Olympus Service
    let sector_id: Int = 3
    let user_id: String = "SOLUM-Test"
    let mode: String = "pdr"
    let key_header = "S3_7F"
    
    let serviceManager = OlympusServiceManager()
    let mapView = OlympusMapViewForScale()
    
    var timer: Timer?
    let TIMER_INTERVAL: TimeInterval = 1 / 10
    
    private var foregroundObserver: Any!
    private var backgroundObserver: Any!
    
    private var startLabel = UILabel().then {
        $0.font = UIFont.pretendardRegular(size: 16)
        $0.textAlignment = .left
        $0.text = "Start"
        $0.textColor = .white
        $0.isUserInteractionEnabled = true
    }
    
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
    
    private let nearbyView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.alpha = 0.5
        view.cornerRadius = 10
        return view
    }()
    
    private var categoryUIView: UIView = {
        let categoryView = UIView()
        categoryView.backgroundColor = .clear
        let markerSize: Double = 24
        categoryView.layer.cornerRadius = markerSize/4
        
        return categoryView
    }()
    
    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.pretendardBold(size: 16)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 8)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let productContentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardBold(size: 12)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
        bindActions()
        personalProfile = PersonalOptionView.selectedLabels
        print("(FindProductView) : personalProfile = \(personalProfile)")
        
        // Olympus Service
        self.notificationCenterAddObserver()
        
        // MapView
        mapView.delegate = self
        mapView.setIsPpHidden(flag: true)
        mapView.setBuildingLevelIsHidden(flag: true)
        OlympusMapManager.shared.loadMapForScale(region: OLYMPUS_REGION, sector_id: sector_id, mapView: mapView)
        setupMapView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopService()
        self.notificationCenterRemoveObserver()
    }
    
    func configure(onCartProducts: [ProductInfo], offCartProducts: [ProductInfo]) {
        self.onCartProducts = onCartProducts
        self.offCartProducts = offCartProducts
        print("(FindProductView) : onCartProduct")
        for item in self.onCartProducts {
            print("(FindProductView) : ID = \(item.id) // profile = \(item.product_profile) // range = \(item.category_range)")
        }
        
        print("(FindProductView) : offCartProducts")
        for item in self.offCartProducts {
            print("(FindProductView) : ID = \(item.id) // profile = \(item.product_profile) // range = \(item.category_range)")
        }
    }
    
    private func plotOnCartProducts(products: [ProductInfo]) {
        mapView.setUnitTags(num: products.count)
        
        categoryDrawed = []
        let mapAndPpScaleValues = mapView.mapAndPpScaleValues
        print("(FindProductView) : plotProduct // mapAndPpScaleValues = \(mapAndPpScaleValues)")
        print("(FindProductView) : plotProduct // products = \(products)")
        
        var productViews = [UIView]()
        for item in products {
            let categoryNumber = item.category_number
            if !categoryDrawed.contains(categoryNumber) {
                let productView = makeOnCartUIView(product: item, scales: mapAndPpScaleValues)
                productViews.append(productView)
                categoryDrawed.append(categoryNumber)
                let categoryInfo = CategoryInfo(name: item.category_name, number: item.category_number, color: item.category_color, x: item.category_x, y: item.category_y, range: item.category_range)
                categoryList.insert(categoryInfo)
            }
            mapView.plotUnitUsingCoord(unitViews: productViews)
        }
    }
    
    private func makeOnCartUIView(product: ProductInfo, scales: [Double]) -> UIView {
        let categoryColor = product.category_color
        let categoryNumber = product.category_number
//        var categoryViewColor = UIColor.white
//        switch(categoryColor) {
//        case "RED":
//            categoryViewColor = RED_COLOR
//        case "GREEN":
//            categoryViewColor = GREEN_COLOR
//        case "YELLOW":
//            categoryViewColor = YELLOW_COLOR
//        case "BLUE":
//            categoryViewColor = BLUE_COLOR
//        case "MAGENTA":
//            categoryViewColor = MAGENTA_COLOR
//        case "WHITE":
//            categoryViewColor = WHITE_COLOR
//        default:
//            categoryViewColor = WHITE_COLOR
//        }
        let categoryViewColor = UIColor(hex: categoryColor)
        
        let x = product.category_x
        let y = -product.category_y
        
        let transformedX = (x - scales[2])*scales[0]
        let transformedY = (y - scales[3])*scales[1]
        
        let rotatedX = transformedX
        let rotatedY = transformedY
        
        let markerSize: Double = 24
        let categoryView = UIView(frame: CGRect(x: rotatedX - markerSize/2, y: rotatedY - markerSize/2, width: markerSize, height: markerSize))
        categoryView.backgroundColor = categoryViewColor
        categoryView.layer.cornerRadius = markerSize/4
        
        let categoryLabel = UILabel()
        categoryLabel.text = "\(categoryNumber)"
        categoryLabel.textAlignment = .center
        categoryLabel.font = UIFont.pretendardBold(size: 12)
        categoryLabel.textColor = .white
        categoryLabel.frame = categoryView.bounds
        categoryLabel.adjustsFontSizeToFitWidth = true
        categoryLabel.minimumScaleFactor = 0.5
        categoryView.addSubview(categoryLabel)
        
        return categoryView
    }
    
    private func makeContentsUI(product: ProductInfo) -> (UIColor, String) {
        let categoryColor = product.category_color
        let categoryNumber = String(product.category_number)
//        var categoryViewColor = UIColor.white
//        switch(categoryColor) {
//        case "RED":
//            categoryViewColor = RED_COLOR
//        case "GREEN":
//            categoryViewColor = GREEN_COLOR
//        case "YELLOW":
//            categoryViewColor = YELLOW_COLOR
//        case "BLUE":
//            categoryViewColor = BLUE_COLOR
//        case "MAGENTA":
//            categoryViewColor = MAGENTA_COLOR
//        case "WHITE":
//            categoryViewColor = WHITE_COLOR
//        default:
//            categoryViewColor = WHITE_COLOR
//        }
        let categoryViewColor = UIColor(hex: categoryColor)
        
        return (categoryViewColor, categoryNumber)
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
        
        addSubview(startLabel)
        startLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(150)
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(headerView.snp.bottom).offset(0)
        }
        
        addSubview(refreshLabel)
        refreshLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(100)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(headerView.snp.bottom).offset(0)
        }
        
        addSubview(aisleGuideImageView)
        aisleGuideImageView.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            make.left.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(refreshLabel.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(aisleGuideImageView.snp.top).offset(-10)
        }
        
        nearbyView.isHidden = true
        addSubview(nearbyView)
        nearbyView.snp.makeConstraints { make in
            make.top.equalTo(refreshLabel.snp.bottom).offset(5)
            make.leading.equalTo(containerView.snp.leading).inset(20)
            make.trailing.equalTo(containerView.snp.trailing).inset(20)
            make.height.equalTo(60)
        }
        
        nearbyView.addSubview(categoryUIView)
        categoryUIView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
        }
        
        categoryUIView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(2)
        }
        
        nearbyView.addSubview(productNameLabel)
        productNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalTo(categoryUIView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        nearbyView.addSubview(productContentsLabel)
        productContentsLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom).offset(5)
            make.leading.equalTo(productNameLabel.snp.leading)
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            self?.onBackTappedInFindProductView?()
        }
        
        headerView.onMenuImageViewTapped = {
            // Menu 버튼 클릭
//            let a = mapView.getMapAndPpScaleValues()
            
            self.mapView.setIsPpHidden(flag: false)
            self.showMapSettingView()
        }
        
        headerView.onPersonImageViewTapped = {
            self.showCoordSettingView()
        }
    }
    
    private func showNearbyProduct(categoryUI: (UIColor, String), title: String, contents: String) {
        DispatchQueue.main.async { [self] in
            
            nearbyView.isHidden = false
            nearbyView.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.nearbyView.alpha = 1.0
            }
            categoryUIView.backgroundColor = categoryUI.0
            categoryLabel.text = categoryUI.1
            productNameLabel.text = title
            productContentsLabel.text = contents

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.nearbyView.alpha = 0.0
                }) { _ in
                    self.nearbyView.isHidden = true
                }
            }
        }
    }
    
    private func showMapSettingView() {
        let mapSettingView = MapSettingView()
        mapSettingView.alpha = 0.5
        mapSettingView.delegate = self
        
        addSubview(mapSettingView)
        mapSettingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let loadScale = loadMapScaleFromCache(key: key_header)
        if loadScale.0, let cachedValues = loadScale.1 {
            print(getLocalTimeString() + " , (FindProductView) cachedValues = \(cachedValues)")
            mapSettingView.configure(with: cachedValues)
            mapView.mapAndPpScaleValues = cachedValues
            mapView.setIsDefaultScale(flag: false)
        } else {
            let defaultScales = mapView.mapAndPpScaleValues
            print(getLocalTimeString() + " , (FindProductView) defaultScales = \(defaultScales)")
            mapSettingView.configure(with: defaultScales)
        }
        
        mapSettingView.onSave = {
            print(getLocalTimeString() + " , (FindProductView) Save Button Tapped")
            let currentScales = mapSettingView.scales
            self.saveMapScaleToCache(key: self.key_header, value: currentScales)
            self.mapView.setIsPpHidden(flag: true)
        }
        
        mapSettingView.onCancel = {
            self.mapView.setIsPpHidden(flag: true)
        }
        
        mapSettingView.onReset = {
            self.mapView.setIsPpHidden(flag: true)
            self.deleteMapScaleFromCache(key: self.key_header)
        }
    }
    
    private func showCoordSettingView() {
        let coordSettingView = CoordSettingView()
        coordSettingView.alpha = 0.5
        
        addSubview(coordSettingView)
        coordSettingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coordSettingView.onSave = {
            let cachedCoords = CoordSettingView.loadCoordFromCache()
            print("Saved Coords: x= \(cachedCoords.x), y= \(cachedCoords.y), heading= \(cachedCoords.heading)")
            
            let cachedStepLength = CoordSettingView.loadStepInfoFromCache()
            print("Saved Step: isFixed= \(cachedStepLength.isUseFixedStep), length= \(cachedStepLength.stepLength)")
        }
    }
    
    private func saveMapScaleToCache(key: String, value: [Double]) {
        print(getLocalTimeString() + " , (FindProductView) Save \(key) scale : \(value)")
        do {
            let key: String = "MapScale_\(key)"
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
    private func loadMapScaleFromCache(key: String) -> (Bool, [Double]?) {
        let keyMapScale: String = "MapScale_\(key)"
        if let loadedMapScale: [Double] = UserDefaults.standard.object(forKey: keyMapScale) as? [Double] {
            print(getLocalTimeString() + " , (FindProductView) Load \(key) scale : \(loadedMapScale)")
            return (true, loadedMapScale)
        } else {
            return (false, nil)
        }
    }
    
    private func deleteMapScaleFromCache(key: String) {
        let cacheKey = "MapScale_\(key)"
        UserDefaults.standard.removeObject(forKey: cacheKey)
        print(getLocalTimeString() + " , (FindProductView) Deleted \(key) scale from cache")
    }
    
    private func setupActions() {
        let startGesture = UITapGestureRecognizer(target: self, action: #selector(startLabelTapped))
        startLabel.addGestureRecognizer(startGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(aisleGuideImageViewTapped))
        aisleGuideImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func startLabelTapped() {
        if isServiceStarted {
            print("(FindProductView) Start Label Tapped : Running -> Stop")
            startLabel.text = "Start"
            isServiceStarted = false
            stopService()
        } else {
            print("(FindProductView) Start Label Tapped : Stop -> Running")
            startLabel.text = "Service is running.."
            isServiceStarted = true
            startService()
        }
    }
        
    @objc private func aisleGuideImageViewTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.aisleGuideImageView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) // Shrink to 90%
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.aisleGuideImageView.transform = .identity
            }
        })
        
        onAisleGuideImageViewTapped?()
    }
    
    private func setupMapView() {
        mapView.configureFrame(to: containerView)
        containerView.addSubview(mapView)
    }
    
    func notificationCenterAddObserver() {
        self.backgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            self.serviceManager.setBackgroundMode(flag: true)
        }
        
        self.foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            self.serviceManager.setBackgroundMode(flag: false)
        }
    }
    
    func notificationCenterRemoveObserver() {
        NotificationCenter.default.removeObserver(self.backgroundObserver)
        NotificationCenter.default.removeObserver(self.foregroundObserver)
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: TIMER_INTERVAL, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode: .common)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    @objc func timerUpdate() {
        
    }
    
    private func startService() {
        let cachedCoords = CoordSettingView.loadCoordFromCache()
        let cachedStep = CoordSettingView.loadStepInfoFromCache()

        let startX = Int(cachedCoords.x)
        let startY = Int(cachedCoords.y)
        let startHeading = cachedCoords.heading
        
        serviceManager.setUseFixedStep(flag: cachedStep.isUseFixedStep)
        serviceManager.setFixedStepLength(value: cachedStep.stepLength)
//        serviceManager.setDeadReckoningMode(flag: true, buildingName: "S3", levelName: "7F", x: startX, y: startY, heading: startHeading)
        serviceManager.setDeadReckoningMode(flag: true, buildingName: "Solum", levelName: "0F", x: startX, y: startY, heading: startHeading)
        
        let uniqueId = makeUniqueId(uuid: self.user_id)
        serviceManager.addObserver(self)
        serviceManager.startService(user_id: uniqueId, region: OLYMPUS_REGION, sector_id: sector_id, service: "FLT", mode: mode, completion: { [self] isStart, returnedString in
            if (isStart) {
                self.startTimer()
            } else {
                print(returnedString)
            }
        })
    }
    
    private func stopService() {
        serviceManager.removeObserver(self)
    }
    
    private func makeUniqueId(uuid: String) -> String {
        let currentTime: Int = getCurrentTimeInMilliseconds()
        let unique_id: String = "\(uuid)_\(currentTime)"
        
        return unique_id
    }
    
    // ESL Activation //
    // Product Check
    private func checkNearbyCategories(user: [Double]) -> [CategoryInfo] {
        var nearbyCategories = [CategoryInfo]()
        let categories = self.categoryList
        for category in categories {
            let range = category.range
            if user[0] >= range[0] && user[0] <= range[1] && user[1] >= range[2] && user[1] <= range[3] {
                nearbyCategories.append(category)
            }
        }
        return nearbyCategories
    }
    
    private func checkMatchingProducts(categoryInfo: CategoryInfo) -> ([ESL], [ProductInfo]) {
        let currentTime = getCurrentTimeInMillisecondsDouble()
        
        var eslList = [ESL]()
        var productsForContents = [ProductInfo]()
        
        // On Cart Check
        for product in self.onCartProducts {
            if product.category_number == categoryInfo.number {
                if let preTime = eslDict[product.id] {
                    if currentTime - preTime > REQ_LED_TIME {
                        let esl = ESL(id: product.id, category_x: product.category_x, category_y: product.category_y, product_name: product.product_name, led_color: self.defaultColor, led_duration: product.led_duration)
                        eslList.append(esl)
                        productsForContents.append(product)
                        eslDict[product.id] = currentTime
                    }
                } else {
                    let esl = ESL(id: product.id, category_x: product.category_x, category_y: product.category_y, product_name: product.product_name, led_color: self.defaultColor, led_duration: product.led_duration)
                    eslList.append(esl)
                    productsForContents.append(product)
                    eslDict[product.id] = currentTime
                }
            }
        }
        
        // Off Cart Check
        for product in self.offCartProducts {
            if product.category_number == categoryInfo.number {
                let ledColor = checkPersonalOption(productProfile: product.product_profile)
                if let preTime = eslDict[product.id] {
                    if currentTime - preTime > REQ_LED_TIME {
                        let esl = ESL(id: product.id, category_x: product.category_x, category_y: product.category_y, product_name: product.product_name, led_color: ledColor, led_duration: product.led_duration)
                        eslList.append(esl)
                        eslDict[product.id] = currentTime
                    }
                } else {
                    let esl = ESL(id: product.id, category_x: product.category_x, category_y: product.category_y, product_name: product.product_name, led_color: ledColor, led_duration: product.led_duration)
                    eslList.append(esl)
                    eslDict[product.id] = currentTime
                }
                
//                if self.personalProfile.contains(product.product_profile) {
//                    if let ledColor = self.profileColorDict[product.product_profile] {
//                        if let preTime = eslDict[product.id] {
//                            if currentTime - preTime > REQ_LED_TIME {
//                                let esl = ESL(id: product.id, category_x: product.category_x, category_y: product.category_y, product_name: product.product_name, led_color: ledColor, led_duration: product.led_duration)
//                                eslList.append(esl)
//                                eslDict[product.id] = currentTime
//                            }
//                        } else {
//                            let esl = ESL(id: product.id, category_x: product.category_x, category_y: product.category_y, product_name: product.product_name, led_color: ledColor, led_duration: product.led_duration)
//                            eslList.append(esl)
//                            eslDict[product.id] = currentTime
//                        }
//                    }
//                }
            }
        }
        
        return (eslList, productsForContents)
    }
    
    private func checkPersonalOption(productProfile: [String]) -> String {
        let overlappingValues: [String] = self.personalProfile.filter { productProfile.contains($0) }
        if overlappingValues.isEmpty {
            return ""
        }
        if overlappingValues.count > 1 {
            return "CYAN"
        } else {
            let overlappingValue = overlappingValues[0]
            if let ledColor = self.profileColorDict[overlappingValue] {
                return ledColor
            } else {
                return defaultColor
            }
        }
    }
    
    private func checkMatchingProductForContents(categoryInfo: CategoryInfo, user: [Double]) -> [ProductInfo] {
        let currentTime = getCurrentTimeInMillisecondsDouble()
        var productsForContents = [ProductInfo]()
        for product in self.onCartProducts {
            if product.category_number == categoryInfo.number {
                if let preTime = productDict[product.id] {
                    if currentTime - preTime > REQ_LED_TIME {
                        let diffX = product.category_x - user[0]
                        let diffY = product.category_y - user[1]
                        let distance = sqrt(diffX*diffX + diffY*diffY)
                        if distance < REQ_DISTANCE {
                            productsForContents.append(product)
                            productDict[product.id] = currentTime
                        }
                    }
                } else {
                    let diffX = product.category_x - user[0]
                    let diffY = product.category_y - user[1]
                    let distance = sqrt(diffX*diffX + diffY*diffY)
                    if distance < REQ_DISTANCE {
                        productsForContents.append(product)
                        productDict[product.id] = currentTime
                    }
                }
            }
        }
        return productsForContents
    }
    
    private func activateValidESLs(validESLs: [ESL]) {
        var ledBlinkList = [ledBlink]()
        for esl in validESLs {
            let ledBlink = ledBlink(labelCode: esl.id, color: esl.led_color, duration: esl.led_duration, patternId: 0, multiLed: false)
            ledBlinkList.append(ledBlink)
        }
        let eslInput = ESL_RUN_INPUT(ledBlinkList: ledBlinkList)
        NetworkManager.shared.putESL(url: SOLUM_ESL_URL, input: eslInput, completion: { [self] statusCode, returnedString in })
    }
    
    private func makeProductContents(user: [Double], product: ProductInfo) -> String {
        let dx = product.category_x - user[0]
        let dy = product.category_y - user[1]

        var relativeAngle = atan2(Double(dy), Double(dx)) * 180 / .pi
        if relativeAngle < 0 { relativeAngle += 360 }

        // Difference between heading and relative angle
        let angleDiff = (relativeAngle - user[2] + 360).truncatingRemainder(dividingBy: 360)
        let adjustedAngleDiff = angleDiff > 180 ? angleDiff - 360 : angleDiff

        // Determine direction
        switch adjustedAngleDiff {
        case -25..<25:
            return "The product is in [ Front ]"
        case 25..<155:
            return "The product is in [ Left ]"
        case -155..<(-25):
            return "The product is in [ Right ]"
        default:
            return "The product is in [ Back ]"
        }
    }
}
