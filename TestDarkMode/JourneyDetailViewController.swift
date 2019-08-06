//
//  JourneyDetailViewController.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/9/27.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

enum JourneyDetailAppearanceStyle {
    case saved
    case published
}

final class JourneyDetailViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var muteButton: UIBarButtonItem!
    
    private let headerView = JourneyDetailHeaderView()
    private let imageViewPlaceholderImage = UIImage.image(with: UIColor(netHex: 0xF2F2F8))
    
    var previewImageUrl: String?
    var journeyId: String!
    var journey: Journey? {
        didSet {
            if let isPublished = journey?.isPublic {
                setAppearance(isPublished ? .published : .saved, isMyJourney: true)
                setLikeCount(journey?.likesCount ?? 0)
                setCommentCount(journey?.commentsCount ?? 0)
                setCollectCount(journey?.collectsCount ?? 0)
                setIsCurrentUserCollected(journey?.isCurrentUserCollect ?? false)
            }
            if let spots = journey?.spots {
                self.spots = spots
            }
        }
    }
    private var shouldDisplayTextInfo: Bool {
        return journey?.tripLog != nil
    }
    
    private var spots = [Spot]()
    private var detailContentOriginalFrame: CGRect?
    private var isDownloading = false
    private var isSliderBarFloating = false
    private var isTopBarRed = false
    private var isMuted = true
    private var shouldDisplayMuteButton = true
    private var sliderBarFloatingConstraints: [NSLayoutConstraint]!
    
    private let metaDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    private let tripDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mma"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter
    }()
    private let tripDurationFormatter: DateComponentsFormatter = {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute]
        durationFormatter.zeroFormattingBehavior = .pad
        return durationFormatter
    }()
    
    private let imageStoryCellId = "imageStoryCellId"
    private let descriptionCellId = "descriptionCellId"
    private let tripsCellId = "tripsCellId"
    private let spotsCellId = "spotsCellId"
    private let metaCellId = "metaCellId"
    private let scrollToTopHeaderViewHeight = CGFloat(54)    
    private var topBarHeight: CGFloat {
        if let statusBarManager = view.window?.windowScene?.statusBarManager {
            return statusBarManager.statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height ?? 0)
        } else {
            return 0
        }
    }

    let topBarAppearance = UINavigationBarAppearance()

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        configureView()
        setTopBarClear(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Stop listening to content offset change and stop updating top bar color
        tableView.delegate = self
        updateTopBar(animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // tableView headerView autoLayout
        // https://stackoverflow.com/a/44391970
        if self.tableView.shouldUpdateHeaderViewFrame() {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.delegate = nil
        setTopBarRed(animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setTopBarClear(animated: false)
    }
    
    private func configureView() {        
        headerView.delegate = self                        
        tableView.setTableHeaderView(headerView)
        configureMuteButton()
    }

    private func makeJourney() -> Journey {
        return Journey(id: "ID",
                    author: User(id: "UID",
                                 name: "NAME",
                                 avatarImage: nil,
                                 thumbnailImage: nil,
                                 birthday: nil,
                                 gender: nil,
                                 phone: "PHONE",
                                 email: "EMAIL"),
                    title: "TITLE",
                    story: "STORY",
                    music: nil,
                    previewImage: nil,
                    tripLog: nil,
                    trip: Trip(routeImage: nil,
                               distance: 1000,
                               startTime: Date() - 86400,
                               endTime: Date(),
                               actualDisplacement: 150),
                    spots: [
                        Spot(id: "ID",
                             journeyId: "JOURNEYID",
                             name: "NAME",
                             lat: 80.0,
                             lon: 80.0)
        ],
                    isPublic: true,
                    reportState: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    publishedAt: Date())
    }

    private func reloadData() {
        isDownloading = true
        configureRightButtonItem(animated: false)
        view.isUserInteractionEnabled = false
        let recover: (() -> Void) = { [weak self] in
            guard let self = self else { return }
            self.isDownloading = false
            self.configureRightButtonItem(animated: false)
            self.view.isUserInteractionEnabled = true
        }
        DispatchQueue.global().async {
            let j = self.makeJourney()
            DispatchQueue.main.async {
                self.journey = j
                self.tableViewReloadData()
                recover()
            }
        }
    }
    
    private func tableViewReloadData() {
        // iOS bug: https://stackoverflow.com/a/19194505
        self.tableView.delegate = nil
        self.tableView.reloadData()
        // set delegate and reloadData() in the next run loop
        DispatchQueue.main.async {
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
    }
    
    func setAppearance(_ appearance: JourneyDetailAppearanceStyle, isMyJourney: Bool) {
        switch appearance {
        case .saved:
            headerView.setAppearance(.saved, isMyJourney: isMyJourney)
        case .published:
            headerView.setAppearance(.published, isMyJourney: isMyJourney)
        }
    }
    
    func setLikeCount(_ count: Int) {
        headerView.setLikeCount(count)
    }
    
    func setCommentCount(_ count: Int) {
        headerView.setCommentCount(count)
    }
    
    func setCollectCount(_ count: Int) {
        headerView.setCollectCount(count)
    }
    
    func setIsCurrentUserCollected(_ collected: Bool) {
        headerView.setIsCurrentUserCollected(collected)
    }
    
    //MARK: - Multi-Media View State
    private func updateMultiMediaViewScale() {
        let contentOffset = tableView.contentOffset
        if contentOffset.y <= 0 {
            headerView.multiMediaContainerView.transform = .pullScrollView(withContentOffset: contentOffset, toScale: headerView.multiMediaContainerView)
        }
    }
    
    //MARK: - Top Bar State
    private func updateTopBar(animated: Bool) {
        if tableView.contentOffset.y >= headerView.lccaView.convert(headerView.lccaView.bounds, to: tableView).minY - topBarHeight {
            guard !isTopBarRed else { return }
            setTopBarRed(animated: animated)
            setTitleHidden(false)
        } else {
            guard isTopBarRed else { return }
            setTopBarClear(animated: animated)
            setTitleHidden(true)
        }
    }
    
    private func setTitleHidden(_ hidden: Bool) {
        if hidden {
            title = ""
        } else {
            title = journey?.title
        }
    }

    func setBarAppearance(_ appearance: UINavigationBarAppearance) {
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        /*
         Xcode 11.0 beta 5 issue:
            The top bar color doesn't react to appearance change. It seems any changes after viewDidLoad() are ignored.
            Not clear if it's intended or a bug.
            As a workaround, we change the value of isNavigationBarHidden to force it to re-render.
         */
        if let hidden = navigationController?.isNavigationBarHidden {
            navigationController?.setNavigationBarHidden(!hidden, animated: false)
            navigationController?.setNavigationBarHidden(hidden, animated: false)
        }
    }
    
    private func setTopBarClear(animated: Bool) {
        isTopBarRed = false
        removeRightButtonItem(animated: false)
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.setBarAppearance(self.topBarAppearance.setTransparentBackground().setBackgroundColor(.clear))
            }, completion: { _ in
                self.configureRightButtonItem(animated: animated)
            })
        } else {
            setBarAppearance(topBarAppearance.setTransparentBackground().setBackgroundColor(.clear))
            configureRightButtonItem(animated: animated)
        }
    }

    func redColor() -> UIColor {
        return UIColor(red: 0xbc/255.0, green: 0x7/255.0, blue: 0x11/255.0, alpha: 1.0)
    }
    
    private func setTopBarRed(animated: Bool) {
        isTopBarRed = true
        removeRightButtonItem(animated: false)
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.setBarAppearance(self.topBarAppearance.setOpaqueBackground().setBackgroundColor(self.redColor()))
            }, completion: { _ in
                self.configureRightButtonItem(animated: animated)
            })
        } else {
            setBarAppearance(self.topBarAppearance.setOpaqueBackground().setBackgroundColor(self.redColor()))
            configureRightButtonItem(animated: animated)
        }
    }

    func removeRightButtonItem(animated: Bool) {
        navigationItem.setRightBarButton(nil, animated: animated)
    }
    
    private func configureRightButtonItem(animated: Bool) {
        switch (isTopBarRed, isDownloading, shouldDisplayMuteButton) {
        case (_, true, _), (false, false, false), (true, _, _):
            navigationItem.setRightBarButton(nil, animated: animated)
        default:
            navigationItem.setRightBarButton(muteButton, animated: animated)
        }
    }
    
    private func configureMuteButton() {
        muteButton.image = isMuted ? UIImage(named:"icon_volume_mute")!.withRenderingMode(.alwaysOriginal) : UIImage(named:"icon_volume_up")!.withRenderingMode(.alwaysOriginal)
    }
    
    //MARK: - Segmented Control State
    private func updateSegmentedControlFloating() {
        let contentOffset = tableView.contentOffset
        if contentOffset.y >= headerView.sliderBarContainerView.convert(headerView.sliderBarContainerView.bounds, to: tableView).minY - topBarHeight {
            guard !isSliderBarFloating else { return }
            detailContentOriginalFrame = headerView.sliderBarContainerView.convert(headerView.sliderBarContainerView.bounds, to: tableView)
            floatSegmentedControl()
        } else if let originalFrame = detailContentOriginalFrame, contentOffset.y < originalFrame.minY - topBarHeight {
            guard isSliderBarFloating else { return }
            stopFloatingSegmentedControl()
            detailContentOriginalFrame = nil
        }
    }
    
    private func floatSegmentedControl() {
        headerView.prepareToFloatSliderBar()        
        view.addSubview(headerView.sliderBarView)
        if #available(iOS 11.0, *) {
            sliderBarFloatingConstraints = [
                headerView.sliderBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                headerView.sliderBarView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                headerView.sliderBarView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                headerView.sliderBarView.heightAnchor.constraint(equalToConstant: 51)
            ]
        } else {
            sliderBarFloatingConstraints = [
                headerView.sliderBarView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                headerView.sliderBarView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                headerView.sliderBarView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                headerView.sliderBarView.heightAnchor.constraint(equalToConstant: 51)
            ]
        }
        NSLayoutConstraint.activate(sliderBarFloatingConstraints)
        isSliderBarFloating = true
    }
    
    private func stopFloatingSegmentedControl() {
        NSLayoutConstraint.deactivate(sliderBarFloatingConstraints)
        headerView.recoverSliderBarFromFloating()
        isSliderBarFloating = false
    }
    
    //MARK: - Indicator Bar State
    private func determineIndicatorBarPosition() {
        let tripsSection = spots.count + 1
        let spotsSection = spots.count + 2
        guard isValidSection(tripsSection) && isValidSection(spotsSection) else { return }
        /*
         We floor it because there may be very tiny float error about 0.00024 for unknown reason.
        */
        let tripsHeaderMinY = floor(tableView.rectForHeader(inSection: tripsSection).minY)
        let spotsHeaderMinY = floor(tableView.rectForHeader(inSection: spotsSection).minY)
        let visibleMinY = tableView.contentOffset.y + topBarHeight + headerView.sliderBarContainerView.bounds.height
        switch visibleMinY {
        case let y where y < tripsHeaderMinY:
            headerView.selectedIndex = 0
        case let y where y < spotsHeaderMinY:
            headerView.selectedIndex = 1
        case let y where y >= spotsHeaderMinY:
            headerView.selectedIndex = 2
        default:
            break
        }
        updateIndicatorBarPosition(true, completion: nil)
    }
    
    private func updateIndicatorBarPosition(_ animated: Bool, completion: ((Bool) -> Void)?) {
        headerView.updateIndicatorBarPosition(animated, completion: completion)
    }
    
    //MARK: - Scrolling
    private func numberOfSections() -> Int {
        return spots.count + (journey != nil ? 4 : 0) //(journey description(1), 0...<spots.count, trips(1), spots(1), meta(1))
    }
    
    private func isValidSection(_ section: Int) -> Bool {
        return section < numberOfSections()
    }
    
    private func scroll(to position: Int) {
        let section: Int
        switch position {
        case 0:
            section = 0
        case 1:
            section = spots.count + 1
        case 2:
            section = spots.count + 2
        default:
            return
        }
        guard isValidSection(section) else { return }
        let rect = tableView.rectForHeader(inSection: section)
        tableView.setContentOffset(CGPoint(x: rect.origin.x, y: rect.origin.y - topBarHeight - headerView.sliderBarContainerView.bounds.height), animated: true)
    }
    
    @objc private func scrollToTop() {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    //MARK: - IBAction
    @IBAction private func scrollToTopButtonPressed(_ sender: Any) {
        scrollToTop()
    }
    
    @IBAction private func muteButtonPressed(_ sender: Any) {
        isMuted = !isMuted
        configureMuteButton()
    }
    
}

extension JourneyDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, spots.count + 1, spots.count + 3:
            return 1
        case 1..<spots.count + 1:
            return spots[section - 1].imageStories?.count ?? 0
        case spots.count + 2:
            return spots.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: descriptionCellId, for: indexPath) as! SpotDescriptionCell
            guard let journey = journey else { return cell }
            cell.configure(journey.story ?? "")
            return cell
        case 1..<spots.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: imageStoryCellId, for: indexPath) as! ImageStoryCell            
            cell.configure(spots[indexPath.section - 1].imageStories?[indexPath.row], placeholderImage: imageViewPlaceholderImage)
            return cell
        case spots.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: tripsCellId, for: indexPath) as! JourneyDetailTripsCell
            let trip = journey?.trip
            cell.configure(trip?.routeImage?.url?.absoluteString,
                           placeholderImage: imageViewPlaceholderImage,
                           distance: String(format: "%.1f",(trip?.distance.flatMap(Double.init) ?? 0.0) / 1000.0),
                           duration: trip?.duration.flatMap(TimeInterval.init).flatMap(tripDurationFormatter.string)?.replacingOccurrences(of: " ", with: ""),
                           displacement: trip?.actualDisplacement.flatMap(String.init),
                           startDate: trip?.startTime.flatMap(tripDateFormatter.string),
                           endDate: trip?.endTime.flatMap(tripDateFormatter.string),
                           shouldDisplayTextInfo: shouldDisplayTextInfo,
                           scrollToTopClosure: { [weak self] in
                            guard let self = self else { return }
                            self.scrollToTop()
            })
            return cell
        case spots.count + 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: spotsCellId, for: indexPath) as! SpotsCell
            cell.configure(indexPath.row + 1, name: spots[indexPath.row].name, showTopBar: indexPath.row != 0, showBottomBar: indexPath.row != spots.count - 1)
            return cell
        case spots.count + 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: metaCellId, for: indexPath) as! JourneyDetailMetaCell
            guard let journey = journey else { return cell }
            cell.configure(journey.createdAt.flatMap(metaDateFormatter.string), creater: journey.author?.name, createrBtnPressedClosure: {})
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
}

extension JourneyDetailViewController: UITableViewDelegate {
    
    private func heightForRow(at indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1..<spots.count + 1:            
            return ImageStoryCell.estimatedHeight(spots[indexPath.section - 1].imageStories?[indexPath.row], width: tableView.bounds.width)
        case 0:
            return SpotDescriptionCell.estimatedHeight(forText: journey?.story ?? "", availableWidth: tableView.bounds.width)
        case spots.count + 1:
            return JourneyDetailTripsCell.estimatedHeight(availableWidth: tableView.bounds.width, shouldDisplayTextInfo: shouldDisplayTextInfo)
        case spots.count + 2:
            return SpotsCell.estimatedHeight()
        case spots.count + 3:            
            return JourneyDetailMetaCell.estimatedHeight()
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(at: indexPath)
    }
    
    private func heightForHeaderInSection(_ section: Int) -> CGFloat {
        switch section {
        case 1..<spots.count + 1:
            return SpotsHeaderView.estimatedCellHeightWithDescription(spots[section - 1].spotDescription, width: tableView.bounds.width)
        case spots.count + 3:
            let extraSpacing = tableView.bounds.height - topBarHeight - headerView.sliderBarContainerView.bounds.height - SpotsCell.estimatedHeight() * CGFloat(spots.count) - JourneyDetailMetaCell.estimatedHeight() - scrollToTopHeaderViewHeight
            return extraSpacing > 0 ? extraSpacing : 0.0
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let cell = cell as? SpotDescriptionCell {
                cell.willDisplay()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1..<spots.count + 1:
            let header = SpotsHeaderView(frame: .zero)
            header.configure(spots[section - 1].name, description: spots[section - 1].spotDescription)
            return header
        case spots.count + 3:
            let header = UIView()
            header.backgroundColor = .white
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? SpotsHeaderView {
            view.willDisplay()
        }
    }
    
    private func heightForFooterInSection(_ section: Int) -> CGFloat {
        switch section {
        case spots.count, spots.count + 1, spots.count + 2:
            return scrollToTopHeaderViewHeight
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection(section)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection(section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case spots.count, spots.count + 1, spots.count + 2:
            let header = ScrollToTopHeaderView(frame: .zero)
            header.configure { [weak self] in
                guard let self = self else { return }
                self.scrollToTop()
            }
            return header
        default:
            return nil
        }
    }
    
}

extension JourneyDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        journeyAnimateVC?.pause()
        updateMultiMediaViewScale()
        updateTopBar(animated: true)
        updateSegmentedControlFloating()
        determineIndicatorBarPosition()
    }
    
}

extension JourneyDetailViewController: JourneyDetailHeaderViewDelegate {
    
    func headerView(_ headerView: JourneyDetailHeaderView, didSelectSegmentAt index: Int) {
        scroll(to: index)
    }
    
    func headerViewDidTapNavigateButton(_ headerView: JourneyDetailHeaderView) {

    }
    
    func headerViewDidTapCollectButton(_ headerView: JourneyDetailHeaderView) {
    }
    
    func headerViewDidTapPublishButton(_ headerView: JourneyDetailHeaderView) {
    }
    
    func headerViewDidTapEditButton(_ headerView: JourneyDetailHeaderView) {
    }
    
    func headerViewDidTapLccaLikeButton(_ headerView: JourneyDetailHeaderView) {
    }
    
    func headerViewDidTapLccaCommentButton(_ headerView: JourneyDetailHeaderView) {
    }
    
    func headerViewDidTapLccaCollectButton(_ headerView: JourneyDetailHeaderView) {
    }
    
    func headerViewDidTapLccaActionButton(_ headerView: JourneyDetailHeaderView) {
    }
    
}
