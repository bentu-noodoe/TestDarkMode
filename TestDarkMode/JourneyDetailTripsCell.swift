//
//  JourneyDetailTripsCell.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/10/8.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit

final class JourneyDetailTripsCell: UITableViewCell {

    @IBOutlet private var previewImageView: CacheImageView!
    @IBOutlet private var textInfoStackView: UIStackView!
    @IBOutlet private var distanceView: UIView!
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var durationView: UIView!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var displacementView: UIView!
    @IBOutlet private var displacementLabel: UILabel!
    @IBOutlet private var datetimeView: UIView!
    @IBOutlet private var startDateLabel: UILabel!
    @IBOutlet private var endDateLabel: UILabel!
    @IBOutlet private var distanceTitleLabel: UILabel!
    @IBOutlet private var durationTitleLabel: UILabel!
    @IBOutlet private var actualDisplacementTitleLabel: UILabel!
    @IBOutlet private var dateTimeTitleLabel: UILabel!
    @IBOutlet private var distanceUnitLabel: UILabel!
    
    private var scrollToTopClosure: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        configureStaticTexts()
        applyBorder(distanceView)
        applyBorder(durationView)
        applyBorder(displacementView)
        applyBorder(datetimeView)
    }
    
    private func configureStaticTexts() {
        distanceTitleLabel.text = String.localizedString("Distance")
        durationTitleLabel.text = String.localizedString("Duration")
        actualDisplacementTitleLabel.text = String.localizedString("ActualDisplacement")
        dateTimeTitleLabel.text = String.localizedString("Date")
        distanceUnitLabel.text = String.localizedString("Distance")
    }
    
    private func applyBorder(_ view: UIView) {
        view.layer.borderColor = UIColor(red: 239, green: 239, blue: 239).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 6
    }
    
    func configure(_ previewImageUrl: String?, placeholderImage: UIImage?, distance: String?, duration: String?, displacement: String?, startDate: String?, endDate: String?, shouldDisplayTextInfo: Bool, scrollToTopClosure: (() -> Void)?) {
        previewImageView.setImageUrl(previewImageUrl, placeholder: placeholderImage)
        textInfoStackView.isHidden = !shouldDisplayTextInfo
        distanceLabel.text = distance ?? ""
        durationLabel.attributedText = formatedDurationString(of: duration ?? "")
        displacementLabel.text = displacement ?? ""
        startDateLabel.text = startDate ?? ""
        endDateLabel.text = endDate ?? ""
        self.scrollToTopClosure = scrollToTopClosure
        
        adjustFontSize(of: distanceLabel)
        adjustFontSize(of: durationLabel)
        adjustFontSize(of: displacementLabel)
        adjustFontSize(of: startDateLabel)
        adjustFontSize(of: endDateLabel)
    }
    
    private func adjustFontSize(of label: UILabel) {
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
    }
    
    private func formatedDurationString(of duration: String) -> NSMutableAttributedString {
        let baseAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 36.0) ?? UIFont.systemFont(ofSize: 36, weight: .bold)]
        let smallAttributes = [NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 18.0) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
        let attributedString = NSMutableAttributedString(string: duration, attributes: baseAttributes)
        
        for (index, scalar) in duration.unicodeScalars.enumerated() {
            if !CharacterSet.decimalDigits.contains(scalar) {
                attributedString.setAttributes(smallAttributes, range: NSRange(location: index, length: 1))
            }
        }
        return attributedString
    }
    
    @IBAction private func scrollToTopButtonPressed(_ sender: Any) {
        scrollToTopClosure?()
    }
    
    static func estimatedHeight(availableWidth: CGFloat, shouldDisplayTextInfo: Bool) -> CGFloat {
        let imageViewHorizontalSpacing = CGFloat(8)
        let verticalSpacing = CGFloat(10)
        let textInfoHeight = CGFloat(221)
        return availableWidth - (2 * imageViewHorizontalSpacing) + (shouldDisplayTextInfo ? verticalSpacing + textInfoHeight : 0)
    }
    
}
