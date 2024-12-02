import UIKit
import SnapKit
import Kingfisher
import OlympusSDK

class FindProductView: UIView, Observer, MapSettingViewDelegate, MapViewForScaleDelegate {
    func mapScaleUpdated() {
        plotProducts(products: self.sortedCartProducts)
    }
    
    func sliderValueChanged(index: Int, value: Double) {
        mapView.updateMapAndPpScaleValues(index: index, value: value)
    }
    
    func update(result: OlympusSDK.FineLocationTrackingResult) {
        let currentIndex = result.index
        if currentIndex > preIndex {
            mapView.updateResultInMap(result: result)
            let userCoord = [result.x, result.y, result.absolute_heading]
            let nearbyEslList = checkNearbyESL(user: userCoord)
            for esl in nearbyEslList {
                activateESL(esl: esl)
                let contents = makeEslContents(user: userCoord, esl: esl)
                showNearbyProduct(url: esl.product_url, title: esl.product_name, contents: contents)
            }
        }
        preIndex = currentIndex
    }
    
    func report(flag: Int) { }
    
    private var sortedCartProducts: [Esl] = []
    var eslDict = [String: Double]()
    let REQ_DISTANCE: Double = 2.0
    let REQ_LED_TIME: Double = 10*1000
    
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
    let sector_id: Int = 2
    let user_id: String = "SOLUM-Test"
    let region: String = "Korea"
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
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        
        // Olympus Service
        self.notificationCenterAddObserver()
        
        // MapView
        mapView.setIsPpHidden(flag: true)
        OlympusMapManager.shared.loadMapForScale(region: "Korea", sector_id: sector_id, mapView: mapView)
        setupMapView()
        mapView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopService()
        self.notificationCenterRemoveObserver()
    }
    
    func configure(with products: [Esl]) {
        self.sortedCartProducts = products
        print("(FindProductView) : Received products: \(products)")
    }
    
    private func plotProducts(products: [Esl]) {
        let mapAndPpScaleValues = mapView.mapAndPpScaleValues
        print("(FindProductView) : plotProduct // mapAndPpScaleValues = \(mapAndPpScaleValues)")
        print("(FindProductView) : plotProduct // products = \(products)")
        for item in products {
            let productView = makeProductUIView(product: item, scales: mapAndPpScaleValues)
            mapView.plotUnitUsingCoord(unitView: productView)
        }
    }
    
    private func makeProductUIView(product: Esl, scales: [Double]) -> UIView {
        let productColor = product.color
        var productViewColor = UIColor.white
        switch(productColor) {
        case "RED":
            productViewColor = RED_COLOR
        case "GREEN":
            productViewColor = GREEN_COLOR
        case "YELLOW":
            productViewColor = YELLOW_COLOR
        case "BLUE":
            productViewColor = BLUE_COLOR
        case "MAGENTA":
            productViewColor = MAGENTA_COLOR
        case "WHITE":
            productViewColor = WHITE_COLOR
        default:
            productViewColor = WHITE_COLOR
        }
        
        let x = product.x
        let y = -product.y
        
        let transformedX = (x - scales[2])*scales[0]
        let transformedY = (y - scales[3])*scales[1]
        
        let rotatedX = transformedX
        let rotatedY = transformedY
        
        let markerSize: Double = 20
        let productView = UIView(frame: CGRect(x: rotatedX - markerSize/2, y: rotatedY - markerSize/2, width: markerSize, height: markerSize))
        productView.backgroundColor = productViewColor
        productView.layer.cornerRadius = markerSize/4
        
        return productView
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
            make.height.equalTo(100)
        }
        
        nearbyView.addSubview(productImageView)
        productImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(120)
        }
        
        nearbyView.addSubview(productNameLabel)
        productNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalTo(productImageView.snp.trailing).offset(20)
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
    }
    
//    private func showNearbyProduct(url: String, title: String, contents: String) {
//        nearbyView.isHidden = false
//        if let url = URL(string: url) {
//            productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
//        }
//        productNameLabel.text = title
//        productContentsLabel.text = contents
//    }
    
    private func showNearbyProduct(url: String, title: String, contents: String) {
        DispatchQueue.main.async { [self] in
            nearbyView.isHidden = false
            nearbyView.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.nearbyView.alpha = 1.0
            }

            if let url = URL(string: url) {
                productImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            }
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

    
//    private func showMapSettingView() {
//        let mapSettingView = MapSettingView()
//        mapSettingView.onConfirm = { [weak self] in
//            print("Confirm tapped")
////            self?.mapView.setIsPpHidden(flag: true)
//        }
//        mapSettingView.onCancel = { [weak self] in
//            print("Cancel tapped")
////            self?.mapView.setIsPpHidden(flag: true)
//        }
//        
//        mapSettingView.onReset = { [weak self] in
//            print("Reset tapped")
////            self?.mapView.setIsPpHidden(flag: true)
//        }
//
//        if let parentView = self.superview {
//            parentView.addSubview(mapSettingView)
//            mapSettingView.snp.makeConstraints { make in
//                make.edges.equalToSuperview()
//            }
//        }
//    }
    
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
        } else {
            print("(FindProductView) Start Label Tapped : Stop -> Running")
            startLabel.text = "Service is running.."
            isServiceStarted = true
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
        startService()
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
        serviceManager.setDeadReckoningMode(flag: true, buildingName: "S3", levelName: "7F", x: 16, y: 13, heading: 180)
        
        let uniqueId = makeUniqueId(uuid: self.user_id)
        serviceManager.addObserver(self)
        serviceManager.startService(user_id: uniqueId, region: region, sector_id: sector_id, service: "FLT", mode: mode, completion: { [self] isStart, returnedString in
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
    private func activateESL(esl: Esl) {
        let esl_id = esl.id
        let esl_color = esl.color
        let esl_duration = esl.duration
        let ledBlink = ledBlink(labelCode: esl_id, color: esl_color, duration: esl_duration, patternId: 0, multiLed: false)
        let eslInput = ESL_RUN_INPUT(ledBlinkList: [ledBlink])
        NetworkManager.shared.putESL(url: SOLUM_ESL_URL, input: eslInput, completion: { [self] statusCode, returnedString in
//            print("(FindProductView) ESL : code = \(statusCode)")
//            print("(FindProductView) ESL : returnedString = \(returnedString)")
        })
    }
    
    private func makeEslContents(user: [Double], esl: Esl) -> String {
        return "This product is on left"
    }
    
    private func checkNearbyESL(user: [Double]) -> [Esl] {
        var nearByEsl = [Esl]()
        
        let products = self.sortedCartProducts
        for product in products {
            let productX = product.x
            let productY = product.y
            
            let diffX = user[0] - productX
            let diffY = user[1] - productY
            let distance = sqrt(diffX*diffX + diffY*diffY)
//            print(getLocalTimeString() + " , (FindProductView) product = \(product.product_name) // distance = \(distance)")
            let currentTime = getCurrentTimeInMillisecondsDouble()
            if distance < REQ_DISTANCE {
                let eslId = product.id
                if let preTagTime = eslDict[eslId] {
                    // 태깅한적 있음
                    if currentTime - preTagTime > REQ_LED_TIME {
                        // Taging한지 10초 지남
                        nearByEsl.append(product)
                    }
                } else {
                    // 최초
                    nearByEsl.append(product)
                }
                eslDict[eslId] = currentTime
            }
        }
//        print(getLocalTimeString() + " , (FindProductView) nearByEsl = \(nearByEsl)")
        
        return nearByEsl
    }
}
