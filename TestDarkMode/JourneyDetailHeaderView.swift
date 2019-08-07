//
//  JourneyDetailHeaderView.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/12.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

protocol JourneyDetailHeaderViewDelegate: class {
    func headerView(_ headerView: JourneyDetailHeaderView, didSelectSegmentAt index: Int)
    func headerViewDidTapNavigateButton(_ headerView: JourneyDetailHeaderView)
    func headerViewDidTapCollectButton(_ headerView: JourneyDetailHeaderView)
    func headerViewDidTapPublishButton(_ headerView: JourneyDetailHeaderView)
    func headerViewDidTapEditButton(_ headerView: JourneyDetailHeaderView)
    func headerViewDidTapLccaLikeButton(_ headerView: JourneyDetailHeaderView)
    func headerViewDidTapLccaCommentButton(_ headerView: JourneyDetailHeaderView)
    func headerViewDidTapLccaCollectButton(_ headerView: JourneyDetailHeaderView)
    func headerViewDidTapLccaActionButton(_ headerView: JourneyDetailHeaderView)
}

enum JourneyDetailHeaderViewAppearanceStyle {
    case saved
    case published
}

final class JourneyDetailHeaderView: UIView, NibOwnerLoadable {

    @IBOutlet var multiMediaContainerView: UIView!
    @IBOutlet var lccaView: UIView!
    @IBOutlet private var actionView: UIView!
    @IBOutlet var sliderBarContainerView: UIView!
    @IBOutlet var sliderBarView: UIView!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var actionStackViewTop: UIStackView!
    @IBOutlet private var actionStackViewBot: UIStackView!
    @IBOutlet private var lccaLikeButton: UIButton!
    @IBOutlet private var lccaCommentButton: UIButton!
    @IBOutlet private var lccaCollectButton: UIButton!
    @IBOutlet private var lccaActionButton: UIButton!
    @IBOutlet private var navigationButton: UIButton!
    @IBOutlet private var collectButton: UIButton!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var publishButton: UIButton!
    
    @IBOutlet private var indicatorBarWidthCons: NSLayoutConstraint!
    @IBOutlet private var sliderBarTopCons: NSLayoutConstraint!
    @IBOutlet private var sliderBarBottomCons: NSLayoutConstraint!
    @IBOutlet private var sliderBarLeadingCons: NSLayoutConstraint!
    @IBOutlet private var sliderBarTrailingCons: NSLayoutConstraint!
    @IBOutlet private var indicatorBarLeadingCons: NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    
    var selectedIndex: Int {
        set {
            segmentedControl.selectedSegmentIndex = newValue
        }
        get {
            return segmentedControl.selectedSegmentIndex
        }
    }
    
    weak var delegate: JourneyDetailHeaderViewDelegate?
    
    private var isCurrentUserCollected = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
        commonInit()
    }
    
    private func commonInit() {
        let normalSegmentedControlTextColor = UIColor(named: "NormalSegmentedControlTextColor")!
        let selectedSegmentedControlTextColor = UIColor(named: "SelectedSegmentedControlTextColor")!

        UISegmentedControl.appearance(whenContainedInInstancesOf: [JourneyDetailHeaderView.self])
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: normalSegmentedControlTextColor,
                                     NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12, weight: .regular)], for: .normal)
        UISegmentedControl.appearance(whenContainedInInstancesOf: [JourneyDetailHeaderView.self])
            .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedSegmentedControlTextColor,
                                     NSAttributedString.Key.font : UIFont(name: "Lato-Regular", size: 12.0) ?? UIFont.systemFont(ofSize: 12, weight: .regular)], for: .selected)
        giveNavigationButtonABorder()
        giveImageViewAImage()
        navigationButton.setTitle(String.localizedString("Navigation"), for: .normal)
        editButton.setTitle(String.localizedString("Edit"), for: .normal)
        publishButton.setTitle(String.localizedString("Publish"), for: .normal)
        segmentedControl.setTitle(String.localizedString("Story"), forSegmentAt: 0)
        segmentedControl.setTitle(String.localizedString("Trips"), forSegmentAt: 1)
        segmentedControl.setTitle(String.localizedString("Spots"), forSegmentAt: 2)
    }

    func giveNavigationButtonABorder() {
        navigationButton.layer.borderWidth = 4.0

        let tc = self.traitCollection

        //1.
        tc.performAsCurrent {
            navigationButton.layer.borderColor = UIColor(named: "SomeKindOfBorderColor")!.cgColor
        }

        //2.
        navigationButton.layer.borderColor = UIColor(named: "SomeKindOfBorderColor")!.resolvedColor(with: tc).cgColor

        //3.
        let savedTc = UITraitCollection.current
        UITraitCollection.current = tc
        navigationButton.layer.borderColor = UIColor(named: "SomeKindOfBorderColor")!.cgColor
        UITraitCollection.current = savedTc
    }

    func giveImageViewAImage() {
        let tc = self.traitCollection
        let image = UIImage(named: "DynamicScene")!
        let asset = image.imageAsset!
        let resolvedImage = asset.image(with: tc)
        imageView.image = resolvedImage
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            giveNavigationButtonABorder()
            giveImageViewAImage()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorBarWidthCons.constant = segmentedControl.bounds.width / CGFloat(segmentedControl.numberOfSegments)
    }
            
    func updateIndicatorBarPosition(_ animated: Bool, completion: ((Bool) -> Void)?) {
        let constant = CGFloat(segmentedControl.selectedSegmentIndex) * segmentedControl.bounds.size.width / CGFloat(segmentedControl.numberOfSegments)
        if animated {
            sliderBarView.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.indicatorBarLeadingCons.constant = constant
                self.sliderBarView.layoutIfNeeded()
            }, completion: { finished in
                completion?(finished)
            })
        } else {
            indicatorBarLeadingCons.constant = constant
            completion?(true)
        }
    }
    
    func setAppearance(_ appearance: JourneyDetailHeaderViewAppearanceStyle, isMyJourney: Bool) {
        switch appearance {
        case .saved:
            actionStackViewTop.isHidden = false
            actionStackViewBot.isHidden = false
            collectButton.isHidden = true
            lccaLikeButton.isEnabled = false
            lccaCommentButton.isEnabled = false
            lccaCollectButton.isEnabled = false
        case .published:
            actionStackViewTop.isHidden = false
            actionStackViewBot.isHidden = true            
            collectButton.isHidden = isMyJourney
            lccaLikeButton.isEnabled = true
            lccaCommentButton.isEnabled = true
            lccaCollectButton.isEnabled = true
        }
    }
    
    func setLikeCount(_ count: Int) {
        lccaLikeButton.setTitle("\(count)", for: .normal)
    }
    
    func setCommentCount(_ count: Int) {
        lccaCommentButton.setTitle("\(count)", for: .normal)
    }
    
    func setCollectCount(_ count: Int) {
        lccaCollectButton.setTitle("\(count)", for: .normal)
    }
    
    func setIsCurrentUserCollected(_ collected: Bool) {
        self.isCurrentUserCollected = collected
        configureCollectButton()
    }
    
    private func configureCollectButton() {
        collectButton.setTitle(isCurrentUserCollected ?
            String.localizedString("Collected") :
            String.localizedString("Collect"), for: .normal)
    }
    
    @IBAction private func segmentedControlValueChanged(_ sender: Any) {
        delegate?.headerView(self, didSelectSegmentAt: segmentedControl.selectedSegmentIndex)
    }
    
    @IBAction private func navigationBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapNavigateButton(self)
    }
    
    @IBAction private func collectBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapCollectButton(self)
    }
    
    @IBAction private func editBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapEditButton(self)
    }
    
    @IBAction private func publishBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapPublishButton(self)
    }
    
    @IBAction private func lccaLikeBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapLccaLikeButton(self)
    }
    
    @IBAction private func lccaCommentBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapLccaCommentButton(self)
    }
    
    @IBAction private func lccaCollectBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapLccaCollectButton(self)
    }
    
    @IBAction private func lccaActionBtnPressed(_ sender: Any) {
        delegate?.headerViewDidTapLccaActionButton(self)
    }
    
}

extension JourneyDetailHeaderView {
    
    func prepareToFloatSliderBar() {
        NSLayoutConstraint.deactivate([sliderBarTopCons, sliderBarBottomCons, sliderBarLeadingCons, sliderBarTrailingCons])
    }
    
    func recoverSliderBarFromFloating() {
        sliderBarContainerView.addSubview(sliderBarView)
        NSLayoutConstraint.activate([sliderBarTopCons, sliderBarBottomCons, sliderBarLeadingCons, sliderBarTrailingCons])
    }
    
}
