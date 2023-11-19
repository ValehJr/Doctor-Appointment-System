//
//  UILabel.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.11.23.
//

import UIKit

extension UILabel {
    func characterIndex(at point: CGPoint) -> Int {
        guard let attributedText = self.attributedText else { return 0 }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()

        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: self.bounds.size)
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return index
    }
}
