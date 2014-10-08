//
//  GraphView.swift
//  Kahn Infection
//
//  Created by Ben Lachman on 10/7/14.
//  Copyright (c) 2014 Ben Lachman. All rights reserved.
//

import UIKit


// MARK: - CGPoint conveinience extension

extension CGPoint {
	// finds the simple distance between two points
	func distanceToPoint(point: CGPoint) -> CGFloat {
		let xDistance = point.x - self.x
		let yDistance = point.y - self.y

		return sqrt((xDistance * xDistance) + (yDistance * yDistance)) // √(x^2+y^2)
	}

	// rotate point 60º clockwise around otherPoint to find a third point (equilateral to others)
	// adapted from: http://stackoverflow.com/a/2862412/159801
	func thirdPoint(otherPoint: CGPoint) -> CGPoint {
		let sin60 = CGFloat(sin(60.0 * M_PI / 180.0))
		let cos60 = CGFloat(cos(60.0 * M_PI / 180.0))

		return CGPointMake(cos60 * (self.x - otherPoint.x) - sin60 * (self.y - otherPoint.y) + otherPoint.x, sin60 * (self.x - otherPoint.x) + cos60 * (self.y - otherPoint.y) + otherPoint.y)
	}
}

// MARK: - Node Protocol

@objc protocol Node {
	func totalWidth() -> Int

	var parents: [Node] { get }
	var children: [Node] { get }

	var cachedPosition: CGPoint { get set }
	var colorIndex: Int { get }
}

// MARK: - GraphTreeViewDataSource

protocol GraphTreeViewDataSource {
	func numberOfLevelsInGraphTreeView(graphTreeView: GraphTreeView) -> Int
	func topLevelNodesInGraphTreeView(graphTreeView: GraphTreeView) -> [AnyObject]
}

// MARK: - GraphTreeView

class GraphTreeView: UIView {
	var dataSource: GraphTreeViewDataSource!
	let margin: CGFloat = 8.0
	private var graphFrame = CGRectZero
	private var nodeColors = [0: UIColor.blueColor()]

	override func drawRect(rect: CGRect) {
		if dataSource == nil {
			return
		}

		graphFrame = CGRectInset(frame, margin, margin)

		let numberOfLevels = dataSource.numberOfLevelsInGraphTreeView(self)
		let levelHeight = CGRectGetHeight(graphFrame) / CGFloat(numberOfLevels)

		var numberOfXPositions = 0
		var topNodes = dataSource.topLevelNodesInGraphTreeView(self)

		for node in topNodes as [Node] {
			// calculate level width
			numberOfXPositions += node.totalWidth()
		}

		let columnWidth = CGRectGetWidth(graphFrame) / CGFloat(numberOfXPositions)
		var nodeOffset: CGFloat = 0

		for index in 0..<topNodes.count {
			// calculate & cache x/y-position of each node
			if let node = topNodes[index] as? Node {
				nodeOffset += calculatePositionsForSubtreeAtNode(node, level: 0, positionMetrics: (nodeOffset, levelHeight, columnWidth))
			}
		}

		for node in topNodes as [Node] {
			// draw connections
			drawConnectionsForSubtreeAtNode(node, level: 0)

			// draw nodes
			drawNodesForSubtreeAtNode(node, level: 0)
		}
	}

	func calculatePositionsForSubtreeAtNode(var node: Node, level: Int, positionMetrics: (xOffset: CGFloat, levelHeight: CGFloat, columnWidth: CGFloat)) -> CGFloat {
		let subtreeWidth = CGFloat(node.totalWidth()) * positionMetrics.columnWidth

		let yPosition = (CGFloat(level) + 0.5) * positionMetrics.levelHeight
		let xPosition = positionMetrics.xOffset + (subtreeWidth/2)

		node.cachedPosition = CGPointMake(xPosition, yPosition)

		var childOffset: CGFloat = positionMetrics.xOffset

		for index in 0..<node.children.count {
			let childWidth = calculatePositionsForSubtreeAtNode(node.children[index], level: level + 1, positionMetrics: (childOffset, positionMetrics.levelHeight, positionMetrics.columnWidth))

			childOffset += childWidth
		}

		return subtreeWidth
	}

	func drawConnectionsForSubtreeAtNode(node: Node, level: Int) {
		// draw the graph bottom up / depth first

		for childNode in node.children {
			drawConnectionsForSubtreeAtNode(childNode, level: level + 1)
		}

		var currentContext = UIGraphicsGetCurrentContext();

		CGContextSetLineWidth(currentContext,1.5);

		for (index, parent) in enumerate(node.parents) {
			let startPosition = node.cachedPosition, endPosition = parent.cachedPosition

			CGContextMoveToPoint(currentContext, startPosition.x, startPosition.y);

			if index == 0 {
				// primary parent gets a solid line
				UIColor.grayColor().set()
				CGContextSetLineDash(currentContext, 0, nil, 0)
				CGContextAddLineToPoint(currentContext, endPosition.x, endPosition.y);
			} else {
				// secondary parent gets a curvy dashed line
				UIColor.greenColor().set()
				CGContextSetLineDash(currentContext, 0, [2.0, 2.0], 2)

				let controlPoint = startPosition.thirdPoint(endPosition)
				CGContextAddQuadCurveToPoint(currentContext, controlPoint.x, controlPoint.y, endPosition.x, endPosition.y)
			}

			CGContextStrokePath(currentContext);
		}
	}

	func drawNodesForSubtreeAtNode(node: Node, level: Int) {
		// draw the graph bottom up / depth first

		for childNode in node.children {
			drawNodesForSubtreeAtNode(childNode, level: level + 1)
		}

		var circle: UIBezierPath = UIBezierPath(arcCenter: node.cachedPosition, radius: CGFloat(4.0), startAngle: CGFloat(0.0), endAngle: CGFloat(M_PI*2), clockwise: true)

		// generate a new random color if we don't have one for this color index
		if let color = nodeColors[node.colorIndex] {
			color.set()
		} else {
			let newColor = UIColor.randomColor()

			nodeColors[node.colorIndex] = newColor
			newColor.set()
		}

		circle.fill()
	}
}
