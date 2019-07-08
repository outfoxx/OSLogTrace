//
//  SignpostTests.swift
//  
//
//  Created by Kevin Wooten on 7/8/19.
//

import Foundation
import XCTest
import OSLogTrace


@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
class SignpostTests: XCTestCase {

  func testManual() {
    let audience = "World"

    let log = OSLogManager.for(subsystem: "Main").for(category: "Tests")
    let spid = log.signpostID()
    log.event(name: "An event", id: spid, message: "Hello \(audience, view: .public)")
    log.begin(name: "An event", id: spid, message: "Hello \(audience, view: .public)")
    log.end(name: "An event", id: spid, message: "Hello \(audience, view: .public)")
  }

  func testAuto() {
    let audience = "World"

    let log = OSLogManager.for(subsystem: "Main").for(category: "Tests")
    let sp = log.signpost()
    sp.event(name: "An event", message: "Hello \(audience)")
    sp.begin(name: "An event", message: "Hello \(audience)")
    sp.end(name: "An event", message: "Hello \(audience)")
  }

}
