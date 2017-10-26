//
//  BeaconRepositoryTests.swift
//  AlpsSDKTests
//
//  Created by Maciej Burda on 26/10/2017.
//  Copyright © 2017 Alps. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Alps
@testable import AlpsSDK

class BeaconRepositoryTests: QuickSpec {
    
    func setupAPI() {
        let headers = [
            "api-key": "c9b9601d-55b9-4057-8331-f1e2c72d308d",
            "Content-Type": "application/json"
        ]
        AlpsAPI.customHeaders = headers
        AlpsAPI.basePath = "http://localhost:9000/v4"
    }
    
    let kWaitTimeInterval = 10.0
    
    override func spec() {
        setupAPI()
        let beaconRepository = BeaconRepository()
        
        context("beacons") {
            fit ("get non existing") {
                var nonExistringBeacon: IBeaconTriple?
                beaconRepository.find(byId: "NONEXISTING_TEST_ID", completion: { (result) in
                    if case let .success(iBeacon) = result {
                        nonExistringBeacon = iBeacon
                    }
                })
                expect(nonExistringBeacon).toEventually(beNil())
            }
        }
    }
}
