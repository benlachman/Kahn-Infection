//
//  Kahn_InfectionTests.swift
//  Kahn InfectionTests
//
//  Created by Ben Lachman on 10/7/14.
//  Copyright (c) 2014 Ben Lachman. All rights reserved.
//

import UIKit
import XCTest
import Kahn_Infection

let peopleToCreate = 150

class Kahn_InfectionTests: XCTestCase {
	var graph = PersonGraph(size: peopleToCreate)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.


    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testBuildGraph() {
		XCTAssertTrue( self.graph.topLevelDoyens.count > 0, "Didn't create any doyens")
	}

	func testNumberOfPeople() {
		var numberOfPeople = 0

		for doyen in graph.topLevelDoyens {
			numberOfPeople += doyen.subgraphCount()
		}

		XCTAssertEqualWithAccuracy(Float(peopleToCreate), Float(numberOfPeople), 30, "Didn't create the right amount of people")
	}

}
