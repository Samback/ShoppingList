//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

// Function to calculate the polar angle between two points
func polarAngle(center: CGPoint, p1: CGPoint, p2: CGPoint) -> CGFloat {
    let vector1 = CGPoint(x: p1.x - center.x, y: p1.y - center.y)
    let vector2 = CGPoint(x: p2.x - center.x, y: p2.y - center.y)

    return atan2(vector1.y, vector1.x) - atan2(vector2.y, vector2.x)
}

// Function for finding the convex hull using the Graham's scan algorithm
func grahamScan(points: [CGPoint]) -> [CGPoint] {
    // Find the point with the lowest y value (and the lowest x value in case of tie)
    let pivot = points.min(by: { (p1, p2) -> Bool in
        if p1.y == p2.y {
            return p1.x < p2.x
        }
        return p1.y < p2.y
    })!

    // Sort other points by the polar angle with respect to the selected point
    let sortedPoints = points.sorted {
        return polarAngle(center: pivot, p1: $0, p2: $1) < 0
    }

    // Stack to store points of the convex hull
    var hull = [CGPoint]()

    // Add the first three points to the stack
    hull.append(contentsOf: sortedPoints.prefix(3))

    // Iterate over the remaining points
    for i in 3..<sortedPoints.count {
        // While the last two points in the stack and the current point do not form a right turn
        while hull.count >= 2 &&
              polarAngle(center: hull[hull.count - 2], p1: hull.last!, p2: sortedPoints[i]) < 0 {
            hull.removeLast()
        }

        // Add the current point to the stack
        hull.append(sortedPoints[i])
    }

    return hull
}

class MyViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black

        view.addSubview(label)
        self.view = view

        // Example usage
        let points: [CGPoint] = [
            CGPoint(x: 1, y: 1),
            CGPoint(x: 2, y: 5),
            CGPoint(x: 3, y: 3),
            CGPoint(x: 5, y: 3),
            CGPoint(x: 5, y: 1),
            CGPoint(x: 4, y: 2)
        ].map {CGPoint(x: $0.x * 50, y: $0.y * 50)}

        let convexHull = grahamScan(points: points)
        print("Convex Hull:", convexHull)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
