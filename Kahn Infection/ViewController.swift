//
//  ViewController.swift
//  Kahn Infection
//
//  Created by Ben Lachman on 10/7/14.
//  Copyright (c) 2014 Ben Lachman. All rights reserved.
//

import UIKit

let numberOfPeople = 100

class ViewController: UIViewController, GraphTreeViewDataSource {
	var graph = PersonGraph(size: numberOfPeople)
	var infectionLimited = false

	@IBOutlet weak var limitSlider: UISlider!
	@IBOutlet weak var limitLabel: UILabel!
	@IBOutlet weak var infectionTypeControl: UISegmentedControl!

	@IBAction func refreshAction(sender: UIButton) {
		graph = PersonGraph(size: numberOfPeople)

		self.view.setNeedsDisplay()
	}

	@IBAction func infectionChangedAction(sender: UISegmentedControl) {
		if sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) == "Limited" {
			infectionLimited = true
			limitLabel.hidden = false
			limitSlider.hidden = false
		} else {
			infectionLimited = false
			limitLabel.hidden = true
			limitSlider.hidden = true
		}
	}

	@IBAction func limitChanged(sender: UISlider) {
		limitLabel.text = "\(Int(sender.value))"
	}

	@IBAction func tap(sender: UITapGestureRecognizer) {
		let (person, distance) = graph.personClosestToPoint(sender.locationInView(view))

		if distance < 15.0 {
			if infectionLimited {
				graph.limitedInfection(startingWithPerson: person, targetNumber: Int(limitSlider.value))
			} else {
				graph.totalInfection(startingWithPerson: person)
			}
		}

		self.view.setNeedsDisplay()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let graphView = view as? GraphTreeView {
			graphView.dataSource = self
		}
		
		// Do any additional setup after loading the view, typically from a nib.
		limitSlider.maximumValue = Float(numberOfPeople)
		limitSlider.value = limitSlider.maximumValue / 2

		limitLabel.text = "\(Int(limitSlider.value))"
	}

	func topLevelNodesInGraphTreeView(graphTreeView: GraphTreeView) -> [AnyObject] {
		return graph.topLevelDoyens 
	}

	func numberOfLevelsInGraphTreeView(graphTreeView: GraphTreeView) -> Int {
		return PersonGraph.maximumNumberOfGraphLevels
	}
}

