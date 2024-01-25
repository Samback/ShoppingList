import Foundation
import UIKit
import Combine

final class CornerView: UIView {

    let subject = PassthroughSubject<String, Never>()
    let coordinateObserver = CurrentValueSubject<CGPoint, Never>(.zero)
    var subscribers = Set<AnyCancellable>()
    var gesture: UIPanGestureRecognizer!
    let circleView = UIView()
    let radius: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialSetup()
    }

    private func initialSetup() {
        attachedGesture()
        addCircle()
        addSubscriber()
    }

    private func addSubscriber() {
        coordinateObserver.value = frame.origin
        coordinateObserver
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] point in
                UIView.animate(withDuration: 0.2) {
                    self?.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
            .store(in: &subscribers)
    }

    private func addCircle() {
        addSubview(circleView)

        circleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(radius * 2)
        }

        circleView.layer.cornerRadius = radius
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.white.cgColor
    }

    private func attachedGesture() {
        isUserInteractionEnabled = true

        gesture = UIPanGestureRecognizer(target: self, action: #selector(handler(gesture:)))
        gesture.maximumNumberOfTouches = 1
        addGestureRecognizer(gesture)
    }


    @objc func handler(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: superview)
        let draggedView = gesture.view
        draggedView?.center = location
        coordinateObserver.send(location)

        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }

}
