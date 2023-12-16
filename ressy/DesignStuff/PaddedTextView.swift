//
//  PaddedTextView.swift
//  ressy
//
//  Created by Valeh Ismayilov on 14.12.23.
//

import UIKit

class PaddedTextView: UITextView {
    
    private let dynamicPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private let placeholderText = "Describe your problem"
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        setupTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextView()
    }
    
    private func setupTextView() {
        textContainerInset = dynamicPadding
        text = placeholderText
        textColor = .lightGray
        delegate = self
    }
}

extension PaddedTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
}

