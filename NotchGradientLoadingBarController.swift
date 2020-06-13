//
//  NotchGradientLoadingBarController.swift
//  GradientLoadingBar
//
//  Created by Felix Mau on 11.06.20.
//

import UIKit

/// Type-alias for the controller to be more similar to the pod name.
/// The notch is only available when supporting safe area layout guides, which is starting from iOS 11.
@available(iOS 11.0, *)
public typealias NotchGradientLoadingBar = NotchGradientLoadingBarController

@available(iOS 11.0, *)
open class NotchGradientLoadingBarController: GradientLoadingBarController {
    // MARK: - Config

    /// Values are based on
    /// <https://www.paintcodeapp.com/news/iphone-x-screen-demystified>
    private enum Config {
        /// The width of the iPhone notch.
        static let notchWidth: CGFloat = 209

        /// The radius of the small circle on the outside of the notch.
        static let smallCircleRadius: CGFloat = 6

        /// The radius of the large circle on the inside of the notch.
        static let largeCircleRadius: CGFloat = 20
    }

    // MARK: - Public methods

    override open func setupConstraints(superview: UIView) {
        // The `safeAreaInsets.top` always includes the status-bar and therefore will always be greater "0".
        // As a workaround we check the bottom inset.
        let hasNotch = superview.safeAreaInsets.bottom > 0
        guard hasNotch else {
            // No special masking required.
            super.setupConstraints(superview: superview)
            return
        }

        // Our view will be masked therefore the view height needs to cover the notch height plus the given user-height.
        let height = 2 * Config.smallCircleRadius + Config.largeCircleRadius + self.height

        NSLayoutConstraint.activate([
            gradientActivityIndicatorView.topAnchor.constraint(equalTo: superview.topAnchor),
            gradientActivityIndicatorView.heightAnchor.constraint(equalToConstant: height),

            gradientActivityIndicatorView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            gradientActivityIndicatorView.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])

        applyNotchMask()
    }

    // MARK: - Private methods

    private func applyNotchMask() {
        // We draw the mask of the notch in the center of the screen.
        // As we currently only support portrait mode, we can safely use `UIScreen.main.bounds` here.
        let screenWidth = UIScreen.main.bounds.size.width
        let leftNotchPoint = (screenWidth - Config.notchWidth) / 2 + 1
        let rightNotchPoint = (screenWidth + Config.notchWidth) / 2

        let smallCircleDiameter: CGFloat = 2 * Config.smallCircleRadius

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 0))

        // Draw line to small-circle left to `leftNotchPoint`.
        bezierPath.addLineTo(x: leftNotchPoint - Config.smallCircleRadius,
                             y: 0)

        // Draw the small circle left to the `leftNotchPoint`.
        // See <https://developer.apple.com/documentation/uikit/uibezierpath/1624358-init#1965853> for the definition of the
        // angles in the default coordinate system.
        bezierPath.addArc(withCenter: CGPoint(x: leftNotchPoint - Config.smallCircleRadius,
                                              y: Config.smallCircleRadius),
                          radius: Config.smallCircleRadius,
                          startAngle: -CGFloat.pi / 2,
                          endAngle: 0,
                          clockwise: true)

        // We're moving the the large-circles a bit closer to the center point.
        // This simulates the "\" and "/" line between the large and the small circles.
        // See: https://medium.com/tall-west/no-cutting-corners-on-the-iphone-x-97a9413b94e
        let horizontalOffsetForLargeCircle: CGFloat = 1

        // Draw the large circle right to the `leftNotchPoint`.
        // Moving it up by three points looked way better.
        let verticalOffsetForLargeCircle: CGFloat = 3
        bezierPath.addArc(withCenter: CGPoint(x: leftNotchPoint + Config.largeCircleRadius + horizontalOffsetForLargeCircle,
                                              y: smallCircleDiameter - verticalOffsetForLargeCircle),
                          radius: Config.largeCircleRadius,
                          startAngle: CGFloat.pi,
                          endAngle: CGFloat.pi / 2,
                          clockwise: false)

        // Draw line to large-circle underneath and left to `rightNotchPoint`.
        bezierPath.addLineTo(x: rightNotchPoint - Config.largeCircleRadius,
                             y: smallCircleDiameter + Config.largeCircleRadius - verticalOffsetForLargeCircle)

        // Draw the large circle left to the `rightNotchPoint`.
        // Moving it up by some points looked way better.
        bezierPath.addArc(withCenter: CGPoint(x: rightNotchPoint - Config.largeCircleRadius - horizontalOffsetForLargeCircle,
                                              y: smallCircleDiameter - verticalOffsetForLargeCircle),
                          radius: Config.largeCircleRadius,
                          startAngle: CGFloat.pi / 2,
                          endAngle: 0,
                          clockwise: false)

        // Draw the small circle right to the `rightNotchPoint`.
        bezierPath.addArc(withCenter: CGPoint(x: rightNotchPoint + Config.smallCircleRadius,
                                              y: Config.smallCircleRadius),
                          radius: Config.smallCircleRadius,
                          startAngle: CGFloat.pi,
                          endAngle: CGFloat.pi + CGFloat.pi / 2,
                          clockwise: true)

        // Draw line to the end of the screen.
        bezierPath.addLineTo(x: screenWidth, y: 0)

        // And all the way back..
        // Therefore we always have to offset the given `height` by the user.
        // As our bezier-path is not perfect, we move it up by one point at the end, so no background is visible between our shape and
        // the frame of the smartphone. Therefore we have to add one point to the user-height here accordingly.
        let height = self.height + 1

        // Start by moving down at the end of the screen.
        bezierPath.addLineTo(x: screenWidth, y: height)

        // Have the small-circle at the bottom only half of the size, produced visually better results.
        let bottomPathSmallCircleRadius = Config.smallCircleRadius / 2

        // Draw line to small-circle right to `rightNotchPoint`.
        bezierPath.addLineTo(x: rightNotchPoint + bottomPathSmallCircleRadius + height,
                             y: height)

        // Draw the small circle right to the `rightNotchPoint`.
        bezierPath.addArc(withCenter: CGPoint(x: rightNotchPoint + bottomPathSmallCircleRadius + height,
                                              y: bottomPathSmallCircleRadius + height),
                          radius: bottomPathSmallCircleRadius,
                          startAngle: -CGFloat.pi / 2,
                          endAngle: -CGFloat.pi,
                          clockwise: false)

        // Draw the large circle left to the `rightNotchPoint`.
        // Moving it up by some points looked way better.
        bezierPath.addArc(withCenter: CGPoint(x: rightNotchPoint - Config.largeCircleRadius + height - horizontalOffsetForLargeCircle,
                                              y: smallCircleDiameter - verticalOffsetForLargeCircle + height),
                          radius: Config.largeCircleRadius,
                          startAngle: 0,
                          endAngle: CGFloat.pi / 2,
                          clockwise: true)

        // Draw line to large-circle underneath and right to `leftNotchPoint`.
        bezierPath.addLineTo(x: leftNotchPoint + Config.largeCircleRadius + height,
                             y: smallCircleDiameter + Config.largeCircleRadius - verticalOffsetForLargeCircle + height)

        // Draw the large circle right to the `leftNotchPoint`.
        // Moving it up by some points looked way better.
        bezierPath.addArc(withCenter: CGPoint(x: leftNotchPoint + Config.largeCircleRadius - height + horizontalOffsetForLargeCircle,
                                              y: smallCircleDiameter - verticalOffsetForLargeCircle + height),
                          radius: Config.largeCircleRadius,
                          startAngle: CGFloat.pi / 2,
                          endAngle: CGFloat.pi,
                          clockwise: true)

        // Draw the small circle left to the `leftNotchPoint`.
        bezierPath.addArc(withCenter: CGPoint(x: leftNotchPoint - bottomPathSmallCircleRadius - height,
                                              y: bottomPathSmallCircleRadius + height),
                          radius: bottomPathSmallCircleRadius,
                          startAngle: 0,
                          endAngle: -CGFloat.pi / 2,
                          clockwise: false)

        // Draw line to the beginning of the screen.
        bezierPath.addLineTo(x: 0, y: height)
        bezierPath.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath

        if #available(iOS 13.0, *) {
            shapeLayer.cornerCurve = .continuous
        }

        // Our shape is not perfect, therefore we move it up by one point, so no background is visible between our shape and
        // the frame of the smartphone.
        shapeLayer.position = CGPoint(x: 0, y: -1)

        gradientActivityIndicatorView.layer.mask = shapeLayer
    }
}

// MARK: - Helpers

private extension UIBezierPath {
    // swiftlint:disable:next identifier_name
    func addLineTo(x: CGFloat, y: CGFloat) {
        addLine(to: CGPoint(x: x, y: y))
    }
}