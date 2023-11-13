//
//  File.swift
//  
//
//  Created by Max Tymchii on 12.11.2023.
//

import Foundation
import UIKit
import Combine

extension NSAttributedString {
    static let counterInProgressAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 22, weight: .medium),
        .foregroundColor: ColorTheme.live().accent.uiColor
    ]

    static let counterDoneAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 22, weight: .medium),
        .foregroundColor: ColorTheme.live().secondary.uiColor
    ]

    static let totalAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14, weight: .regular),
        .foregroundColor: ColorTheme.live().secondary.uiColor
    ]

}

public extension CounterView {

    struct Counter {
        let current: Int
        let total: Int

      public init(current: Int, total: Int) {
            self.current = current
            self.total = total
        }
    }

    static var publisher = PassthroughSubject<Counter, Never>()
}

public class CounterView: UIView {

    let defaultHeight: CGFloat = 34

    private var subscriptions = Set<AnyCancellable>()

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let slashLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let backgroundView = UIView()

    public convenience init(counter: Counter) {
        self.init(frame: .zero)
        setValues(counter: counter.current, total: counter.total)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {

        CounterView.publisher
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] counter in
            self?.setValues(counter: counter.current, total: counter.total)
        }.store(in: &subscriptions)

        addSubview(backgroundView)
        backgroundView.backgroundColor = ColorTheme.live().surfaceSecondary.uiColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        [counterLabel, slashLabel, totalLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        NSLayoutConstraint.activate([
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            slashLabel.leadingAnchor.constraint(equalTo: counterLabel.trailingAnchor, constant: 4),
            slashLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            totalLabel.leadingAnchor.constraint(equalTo: slashLabel.trailingAnchor, constant: 4),
            totalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            totalLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: defaultHeight)
        ])

        layer.cornerRadius = defaultHeight / 2.0
        layer.masksToBounds = true
        backgroundColor = ColorTheme.live().white.uiColor
    }

    private func setValues(counter: Int, total: Int) {
        let counterAttributes = counter == total ? NSAttributedString.counterDoneAttributes : NSAttributedString.counterInProgressAttributes

        counterLabel.attributedText = .init(string: "\(counter)", attributes: counterAttributes)
        slashLabel.attributedText = .init(string: "/", attributes: NSAttributedString.totalAttributes)
        totalLabel.attributedText = .init(string: "\(total)", attributes: NSAttributedString.totalAttributes)

        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.33, delay: 0, options: [.beginFromCurrentState]) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }

    deinit {
        print("CounterView deinit")
    }
}

#Preview {
    let counterView = CounterView()
    CounterView.publisher.send(.init(current: 1, total: 10))
    return counterView

}
