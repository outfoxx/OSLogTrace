//
//  SignpostTests.swift
//  OSLogTrace
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import OSLogTrace
import XCTest

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
