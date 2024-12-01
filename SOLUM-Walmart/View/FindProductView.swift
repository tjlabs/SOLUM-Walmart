import UIKit
import SnapKit
import OlympusSDK

class FindProductView: UIView, Observer {
    func update(result: OlympusSDK.FineLocationTrackingResult) { }
    func report(flag: Int) { }
    
    private var sortedCartProducts: [Esl] = []
    
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
    
    // Olympus Service
    let sector_id: Int = 2
    let user_id: String = "SOLUM-Test"
    let region: String = "Korea"
    let mode: String = "pdr"
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
        bindActions()
        
        // Olympus Service
        self.notificationCenterAddObserver()
        
        // MapView
        let loadScale = loadMapScaleFromCache(key: "S3_7F")
        if loadScale.0 {
            // cache에 정보가 있으면
        } else {
            // cache에 정보가 없으면
        }
        mapView.setIsPpHidden(flag: false)
        OlympusMapManager.shared.loadMapForScale(region: "Korea", sector_id: sector_id, mapView: mapView)
        setupMapView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.notificationCenterRemoveObserver()
    }
    
    func configure(with products: [Esl]) {
        self.sortedCartProducts = products
        print("Received products: \(products)")
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
    }
    
    private func bindActions() {
        headerView.onBackImageViewTapped = { [weak self] in
            self?.onBackTappedInFindProductView?()
        }
        
        headerView.onMenuImageViewTapped = {
            // Menu 버튼 클릭
//            let a = mapView.getMapAndPpScaleValues()
            
//            self.mapView.setIsPpHidden(flag: false)
            self.showMapSettingView()
        }
    }
    
    private func showMapSettingView() {
        let mapSettingView = MapSettingView()
        mapSettingView.onConfirm = { [weak self] in
            print("Confirmed checkout")
//            self?.mapView.setIsPpHidden(flag: true)
        }
        mapSettingView.onCancel = { [weak self] in
            print("Checkout canceled")
//            self?.mapView.setIsPpHidden(flag: true)
        }

        if let parentView = self.superview {
            parentView.addSubview(mapSettingView)
            mapSettingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
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
                self.aisleGuideImageView.transform = .identity // Reset to original scale
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
}
