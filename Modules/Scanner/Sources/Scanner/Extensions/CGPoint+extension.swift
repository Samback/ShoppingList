//
//  File.swift
//  
//
//  Created by Max Tymchii on 07.12.2023.
//

import Foundation

extension Collection where Element == CGPoint {

  func getHull() -> [CGPoint] {
    guard let first = self.first else {
      return []
    }

    let anchor = self.reduce(first) { smallest, compare in
      if compare.y < smallest.y {
        return compare
      } else if compare.y == smallest.y && compare.x < smallest.x {
        return compare
      } else {
        return smallest
      }
    }

    let sortedPointsWithIndex = self.enumerated().sorted { a, b in
      let (_, pta) = a
      let (_, ptb) = b
        return pta.theta(anchor: anchor) < ptb.theta(anchor: anchor)
    }

    let sortedPoints = sortedPointsWithIndex.map { _, point in
      return point
    }

    var hull = [CGPoint]()
    hull.append(sortedPoints[0])
    hull.append(sortedPoints[1])

    for i in 2..<sortedPoints.count {
      var top = hull.removeLast()
      while hull.count > 0 && !sortedPoints[i].continuesLeftTurn(first: hull.last!, middle: top) {
        top = hull.removeLast()
      }
      hull.append(top)
      hull.append(sortedPoints[i])
    }

    return hull
  }
}

extension CGPoint {

    func theta(anchor: CGPoint) -> Float {
      let dx = Float(x - anchor.x)
      let dy = Float(y - anchor.y)

      let t = dy / (abs(dx) + abs(dy))

      if dx == 0 && dy == 0 {
        return 0
      } else if dx < 0 {
        return 2 - t
      } else if dy < 0 {
        return 4 + t
      } else {
        return t
      }
    }

    func continuesLeftTurn(first: CGPoint, middle: CGPoint) -> Bool {
      return (first.x - x) * (middle.y - y) - (first.y - y) * (middle.x - x) > 0
    }
}
