//
//  File.swift
//
//
//  Created by Max Tymchii on 29.12.2023.
//

import Foundation
import UIKit
import SnapKit
import Theme

extension TextListViewController {
    static func makeViewController(with image: UIImage) -> TextListViewController {
        let viewController = TextListViewController(nibName: nil, bundle: nil)
        viewController.image = image
        return viewController
    }
}

final class TextListViewController: UIViewController {

    private var image: UIImage?

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.tintColor = ColorTheme.live().primary.uiColor
        textView.backgroundColor = .clear
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8

        textView.typingAttributes = [
            NSAttributedString.Key.foregroundColor: ColorTheme.live().primary.uiColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19),
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        textView.showsVerticalScrollIndicator = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        parseText()
    }

    private func setupUI() {
        view.backgroundColor = ColorTheme.live().surface_1.uiColor

        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(24)
            make.bottom.trailing.equalToSuperview().offset(-24)
        }
    }

    private func parseText() {
        Task {
            let texts = await textRecognise()
            let sanitizedTexts = textSanitize(texts)
            let text = sanitizedTexts.joined(separator: "\n")

            await MainActor.run {
                self.textView.text = text
            }
        }
    }

    private func textRecognise() async -> [String] {
        guard let image = image else {
            return []
        }

        let result = await TextRecognitionService
            .liveValue
            .recognizeText([image])

        return result
    }

    private func textSanitize(_ texts: [String]) -> [String] {
        TextSanitizer.sanitize(texts)
    }

    public func listTexts() -> [String] {
        guard let text = textView.text else {
            return []
        }
        return text.components(separatedBy: .newlines)
    }
}
