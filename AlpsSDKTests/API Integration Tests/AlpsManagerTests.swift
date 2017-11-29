//
//  AlpsManagerTests.swift
//  AlpsSDKTests
//
//  Created by Maciej Burda on 27/10/2017.
//  Copyright © 2017 Alps. All rights reserved.
//

import Foundation

import Quick
import Nimble

@testable import Alps
@testable import AlpsSDK

final class AlpsManagerTests: QuickSpec {
    
    override func spec() {
        let properties = ["test": "true"]
        let location = Location(latitude: 10, longitude: 10, altitude: 10, horizontalAccuracy: 10, verticalAccuracy: 10)
        
        MatchMore.apiKey = TestsConfig.kApiKey
        MatchMore.worldId = TestsConfig.kWorldId
        var alpsManager = MatchMore.manager
        
        var errorResponse: ErrorResponse?
        
        context("Alps Manager") {
            
            beforeEach {
                errorResponse = nil
            }
            
            fit ("clear publications") {
                waitUntil(timeout: TestsConfig.kWaitTimeInterval * 4) { done in
                    alpsManager.publications.deleteAll { error in
                        errorResponse = error
                        done()
                    }
                }
                expect(alpsManager.publications.items).to(beEmpty())
                expect(errorResponse?.message).toEventually(beNil())
            }
            
            fit ("clear subscriptions") {
                waitUntil(timeout: TestsConfig.kWaitTimeInterval * 4) { done in
                    alpsManager.subscriptions.deleteAll { error in
                        errorResponse = error
                        done()
                    }
                }
                expect(alpsManager.subscriptions.items).to(beEmpty())
                expect(errorResponse?.message).toEventually(beNil())
            }
            
            fit ("clear mobile devices") {
                waitUntil(timeout: TestsConfig.kWaitTimeInterval * 4) { done in
                    alpsManager.mobileDevices.deleteAll { error in
                        errorResponse = error
                        done()
                    }
                }
                expect(alpsManager.mobileDevices.main).to(beNil())
                expect(alpsManager.mobileDevices.items).to(beEmpty())
                expect(errorResponse?.message).toEventually(beNil())
            }
            
            fit ("create main device") {
                waitUntil(timeout: TestsConfig.kWaitTimeInterval) { done in
                    MatchMore.startUsingMainDevice { result in
                        if case .failure(let error) = result {
                            errorResponse = error
                        }
                        done()
                    }
                }
                expect(alpsManager.mobileDevices.main).toEventuallyNot(beNil())
                expect(alpsManager.mobileDevices.items).toEventuallyNot(beEmpty())
                expect(errorResponse?.message).toEventually(beNil())
            }
            
            fit ("create a publication") {
                let publication = Publication(topic: "Test Topic", range: 20, duration: 100000, properties: properties)
                waitUntil(timeout: TestsConfig.kWaitTimeInterval) { done in
                    MatchMore.createPublication(publication: publication, completion: { (result) in
                        if case .failure(let error) = result {
                            errorResponse = error
                        }
                        done()
                    })
                }
                expect(alpsManager.publications.items).toEventuallyNot(beEmpty())
                expect(errorResponse?.message).toEventually(beNil())
            }
            
            fit ("create a subscription") {
                let subscription = Subscription(topic: "Test Topic", range: 20, duration: 100000, selector: "test = 'true'")
                waitUntil(timeout: TestsConfig.kWaitTimeInterval) { done in
                    MatchMore.createSubscription(subscription: subscription, completion: { (result) in
                        if case .failure(let error) = result {
                            errorResponse = error
                        }
                        done()
                    })
                }
                expect(alpsManager.subscriptions.items).toEventuallyNot(beEmpty())
                expect(errorResponse?.message).toEventually(beNil())
            }
            
            fit ("recover state") {
                // simulates turning app off and on again
                alpsManager = AlpsManager(apiKey: TestsConfig.kApiKey,
                                          baseURL: TestsConfig.kBaseUrl)
                expect(alpsManager.mobileDevices.main).toNot(beNil())
                expect(alpsManager.mobileDevices.items).toNot(beEmpty())
            }
            
            fit ("update location") {
                if let mainDeviceId = alpsManager.mobileDevices.main?.id {
                    alpsManager.locationUpdateManager.tryToSend(location: location, for: mainDeviceId)
                }
                expect(alpsManager.locationUpdateManager.lastLocation?.longitude).toEventuallyNot(beNil())
                expect(alpsManager.locationUpdateManager.lastLocation?.latitude).toEventuallyNot(beNil())
            }
            
            fit ("get polling match") {
                var deliveredMatches: [Match]?
                alpsManager.matchMonitor.startPollingMatches()
                let matchDelegate = MatchDelegate()
                alpsManager.delegates += matchDelegate
                alpsManager.matchMonitor.startMonitoringFor(device: alpsManager.mobileDevices.main!)
                
                waitUntil(timeout: TestsConfig.kWaitTimeInterval) { done in
                    matchDelegate.onMatch = { matches, _ in
                        deliveredMatches = matches
                        alpsManager.matchMonitor.stopPollingMatches()
                        done()
                    }
                }
                expect(deliveredMatches).toEventuallyNot(beEmpty())
            }
            
            fit ("get socket match") {
                var deliveredMatches: [Match]?
                alpsManager.matchMonitor.openSocketForMatches()
                let matchDelegate = MatchDelegate()
                alpsManager.delegates += matchDelegate
                
                waitUntil(timeout: TestsConfig.kWaitTimeInterval) { done in
                    matchDelegate.onMatch = { matches, _ in
                        deliveredMatches = matches
                        alpsManager.matchMonitor.closeSocketForMatches()
                        done()
                    }
                    let subscription = Subscription(topic: "Test Topic", range: 20, duration: 100000, selector: "test = 'true'")
                    subscription.pushers?.append("ws")
                    MatchMore.createSubscription(subscription: subscription, completion: { (result) in
                        if case .failure(let error) = result {
                            errorResponse = error
                        }
                    })
                }
                expect(deliveredMatches).toEventuallyNot(beEmpty())
            }
        }
    }
    
    class MatchDelegate: AlpsDelegate {
        var onMatch: OnMatchClosure?
        init(_ onMatch: OnMatchClosure? = nil) {
            self.onMatch = onMatch
        }
    }
}
