//
//  Model.swift
//  Kahn Infection
//
//  Created by Ben Lachman on 10/7/14.
//  Copyright (c) 2014 Ben Lachman. All rights reserved.
//

import UIKit


@objc class PersonOfLetters: Node {
	internal private(set) var doyens = [PersonOfLetters]() // An obscure, yet fun, word that means coach, http://www.merriam-webster.com/dictionary/doyen
	internal private(set) var abecedarians = [PersonOfLetters]() // A fun, yet obscure, word that means pupil, http://www.merriam-webster.com/dictionary/abecedarian

	var unlimitedInfection = true

	var infectionStrain: Int = 0 {
		didSet {
			if unlimitedInfection && infectionStrain != oldValue {
				infectDoyens()
				infectAbecedarians()
			}
		}
	}

	func infectDoyens() {
		for doyen in doyens {
			if unlimitedInfection == false {
				doyen.unlimitedInfection = false
				doyen.infectionStrain = infectionStrain
				doyen.unlimitedInfection = true
			} else {
				doyen.infectionStrain = infectionStrain
			}
		}
	}

	func infectAbecedarians() {
		for abecedarian in abecedarians {
			if unlimitedInfection == false {
				abecedarian.unlimitedInfection = false
				abecedarian.infectionStrain = infectionStrain
				abecedarian.unlimitedInfection = true
			} else {
				abecedarian.infectionStrain = infectionStrain
			}
		}
	}

	func addAbecedarian(newAbecedarian: PersonOfLetters) {
		// update infection strain appropriately
		if newAbecedarian.infectionStrain < infectionStrain {
			newAbecedarian.infectionStrain = infectionStrain
		} else if newAbecedarian.infectionStrain > infectionStrain {
			infectionStrain = newAbecedarian.infectionStrain
		}

		abecedarians.append(newAbecedarian)
	}

	func addDoyen(newDoyen: PersonOfLetters) {
		// update infection strain appropriately
		if newDoyen.infectionStrain < infectionStrain {
			newDoyen.infectionStrain = infectionStrain
		} else if newDoyen.infectionStrain > infectionStrain {
			infectionStrain = newDoyen.infectionStrain
		}

		doyens.append(newDoyen)
	}

	// MARK: - Utilities

	func randomAbecedarian() -> PersonOfLetters? {
		if abecedarians.count > 0 {
			return abecedarians[Int.random(lower: 0, upper: abecedarians.count)]
		} else {
			return nil
		}
	}

	func closestToPoint(point: CGPoint) -> (person: PersonOfLetters, distance: CGFloat) {
		if abecedarians.count == 0 {
			return (self, self.cachedPosition.distanceToPoint(point))
		}

		var closestToPoint = (person: self, distance: self.cachedPosition.distanceToPoint(point))

		for abecedarian in abecedarians {
			let closest = abecedarian.closestToPoint(point)

			if closest.distance < closestToPoint.distance {
				closestToPoint = closest
			}
		}

		// returns a tuple containing a person and their distance to the point
		return closestToPoint
	}

	public func mostInfectedAbecedarians(infectedStrain: Int) -> (person: PersonOfLetters, numberInfected: Int) {
		if abecedarians.count == 0 {
			return (self, 0)
		}

		var abecedariansInfected = abecedarians.filter({ $0.infectionStrain == infectedStrain }).count

		if self.infectionStrain == infectedStrain {
			// if we're already infected with this strain, any other person is better than self
			abecedariansInfected = -1
		}

		var mostInfected = (person: self, numberInfected: abecedariansInfected)

		for abecedarian in abecedarians {
			let most = abecedarian.mostInfectedAbecedarians(infectedStrain)

			if most.numberInfected > mostInfected.numberInfected {
				mostInfected = most
			}
		}

		// returns tuple containing a person and the number of their immediate abecedarians that are infected
		return mostInfected
	}


	// MARK: - Node Protocol

	func totalWidth() -> Int {
		if abecedarians.count == 0 {
			return 1
		}

		var width = 0

		for person in abecedarians {
			width += person.totalWidth()
		}

		return width
	}

	var parents: [Node] {
		get {
			return self.doyens
		}
	}

	var children: [Node] {
		get {
			return self.abecedarians
		}
	}

	var cachedPosition: CGPoint = CGPointZero

	var colorIndex: Int {
		get {
			return infectionStrain
		}
	}
}
