//
//  PaddedTextView.swift
//  ressy
//
//  Created by Valeh Ismayilov on 14.12.23.
//

import UIKit

extension UITextView {
    func leftSpace() {
        self.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    
    func addPlaceholder(_ placeholder: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 999
        placeholderLabel.isHidden = !text.isEmpty
        addSubview(placeholderLabel)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left + 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -textContainerInset.right)
        ])
    }
}

extension InformationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let placeholderLabel = textView.viewWithTag(999) as? UILabel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            placeholderLabel?.isHidden = !textView.text.isEmpty
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        let placeholderLabel = textView.viewWithTag(999) as? UILabel
        placeholderLabel?.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let placeholderLabel = textView.viewWithTag(999) as? UILabel
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
}

