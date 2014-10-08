//
//  PersonGraph.swift
//  Kahn Infection
//
//  Created by Ben Lachman on 10/8/14.
//  Copyright (c) 2014 Ben Lachman. All rights reserved.
//

import UIKit


private let _maximumNumberOfGraphLevels = Int.random(lower:3, upper:8) // 3 - 8 levels in the graph

@objc class PersonGraph {
	internal private(set) var topLevelDoyens = [PersonOfLetters]()
	private var infectionStrain = 0

	class var maximumNumberOfGraphLevels: Int {
		get {
			return _maximumNumberOfGraphLevels
		}
	}

	convenience init(size: Int) {
		self.init()

		buildGraph(size: size)
	}

	// MARK: - Infection algorithm methods

	func totalInfection(startingWithPerson person: PersonOfLetters) {
		person.infectionStrain = ++infectionStrain
	}

	func limitedInfection(startingWithPerson person: PersonOfLetters, targetNumber: Int) {
		var numberInfected = person.abecedarians.count

		person.unlimitedInfection = false
		person.infectionStrain = ++infectionStrain
		person.infectAbecedarians()
		person.unlimitedInfection = true

		while numberInfected < targetNumber {
			var nextToInfect = doyenWithMostInfectedAbecedarians(infectionStrain)

			if nextToInfect.infectionStrain != infectionStrain {
				nextToInfect.unlimitedInfection = false
				nextToInfect.infectionStrain = infectionStrain
				nextToInfect.infectAbecedarians()
				nextToInfect.unlimitedInfection = true

				numberInfected += nextToInfect.abecedarians.count
			}
		}
	}

	// MARK: - Graph Buiding Methods

	func buildGraph(size: Int = 500) {
		let numberOfTopLevelDoyens = Int.random(lower: 2, upper: (size / PersonGraph.maximumNumberOfGraphLevels))// 2 - (size / maximumNumberOfGraphLevels) top doyens
		var totalStudents = numberOfTopLevelDoyens

		for index in 0..<numberOfTopLevelDoyens {
			var newDoyen = PersonOfLetters()
			var numberOfAbecedarians = Int.random(lower: 0, upper: (size / (numberOfTopLevelDoyens / 2)) + 1)

			if numberOfAbecedarians > (size - totalStudents) {
				numberOfAbecedarians = size - totalStudents
			}

			if numberOfAbecedarians > 0 {
				buildSubGraph(forDoyen:newDoyen, withSize: numberOfAbecedarians, atGraphLevel:1)
			}

			totalStudents += numberOfAbecedarians
			topLevelDoyens.append(newDoyen)
		}
	}

	private func buildSubGraph(forDoyen doyen: PersonOfLetters, withSize sizeRequested: Int = 20, atGraphLevel graphLevel: Int = 0) {
		// randomly recursively create a sub graph of abecedarians such that the subgraph contains roughly the number of abecedarians requested

		if graphLevel == (PersonGraph.maximumNumberOfGraphLevels - 1) || sizeRequested == 1 {
			// exit condiditions: reached maximum level or only have one abecedarian to create
			createAbecedarians(forDoyen: doyen, count: sizeRequested)

			return
		}

		var numberOfNewlyCreatedAbecedarians = Int.random(lower: 1, upper: sizeRequested)

		createAbecedarians(forDoyen: doyen, count: numberOfNewlyCreatedAbecedarians)

		var totalCountCreated = numberOfNewlyCreatedAbecedarians
		var index = 0

		while totalCountCreated < sizeRequested {
			let abecedariansLeftToCreate = sizeRequested - totalCountCreated

			var nextLevelSize = 0

			if index == doyen.abecedarians.count - 1 {
				// if we're filling in the last of our new abecedarians, have it create all the remaining requested abecedarians
				nextLevelSize = abecedariansLeftToCreate
			} else if( numberOfNewlyCreatedAbecedarians > 1 ) {
				// otherwise assign this abecedarian a random number of sub-abecedarians to create recursively
				let maxAbecedariansToCreate = (abecedariansLeftToCreate / (numberOfNewlyCreatedAbecedarians / 2))

				if maxAbecedariansToCreate > 0 {
					nextLevelSize = Int.random(lower: 0, upper: maxAbecedariansToCreate)
				}
			}

			if( nextLevelSize > 0 ) {
				buildSubGraph(forDoyen: doyen.abecedarians[index], withSize: nextLevelSize, atGraphLevel: graphLevel+1)
				totalCountCreated += nextLevelSize
			}

			++index
		}
	}

	private func createAbecedarians(forDoyen doyen: PersonOfLetters, count: Int) {
		for index in 0..<count {
			var newAbecedarian = PersonOfLetters()
			newAbecedarian.infectionStrain = doyen.infectionStrain

			doyen.addAbecedarian(newAbecedarian)
			newAbecedarian.addDoyen(doyen)

			addAdditionalDoyen(toAbecedarian: newAbecedarian)
		}
	}

	private func addAdditionalDoyen(toAbecedarian abecedarian: PersonOfLetters) {
		// possibly add one or more additional Doyens to a Abecedarian

		if( topLevelDoyens.count == 0 ) {
			return
		}

		if Int.random(lower: 0, upper: 100) >= 90 { // 10% chance
			// link to an additional doyen
			let level = Int.random(lower: 0, upper: PersonGraph.maximumNumberOfGraphLevels)
			let additionalDoyen = randomPerson(onLevel: level)

			if additionalDoyen !== abecedarian {
				abecedarian.addDoyen(additionalDoyen)
				additionalDoyen.addAbecedarian(abecedarian)
			}

			// recursively add another possible doyen
			addAdditionalDoyen(toAbecedarian: abecedarian)
		}
	}

	// MARK: - Ways To Find People

	func randomPerson(onLevel level: Int) -> PersonOfLetters {
		// randomly traverse the graph to find a person
		var doyen = topLevelDoyens[Int.random(lower: 0, upper: topLevelDoyens.count)]

		for index in 0..<level {
			if let foundDoyen = doyen.randomAbecedarian() {
				doyen = foundDoyen
			} else {
				break
			}
		}

		return doyen
	}

	func personClosestToPoint(point: CGPoint) -> (person: PersonOfLetters, distance: CGFloat) {
		// recursively traverse the graph finding the person that is closest to the point
		var closestToPoint = (person: topLevelDoyens[0], distance: CGFloat.max)

		for doyen in topLevelDoyens {
			let closest = doyen.closestToPoint(point)

			if closest.distance < closestToPoint.distance {
				closestToPoint = closest
			}
		}

		return closestToPoint
	}

	func doyenWithMostInfectedAbecedarians(intefectedStrain: Int) -> PersonOfLetters {
		// recursively find the doyen with the most infected abecedarians, if there isn't one return a random person
		var mostInfected = (person: randomPerson(onLevel: Int.random(lower: 0, upper: PersonGraph.maximumNumberOfGraphLevels)), numberInfected: 0)

		for doyen in topLevelDoyens {
			let most = doyen.mostInfectedAbecedarians(intefectedStrain)

			if most.numberInfected > mostInfected.numberInfected {
				mostInfected = most
			}
		}
		
		return mostInfected.person
	}
}
