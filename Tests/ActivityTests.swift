//
//  ActivityTests.swift
//  OSLogTrace
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import OSLogTrace
import XCTest

class ActivityTests: XCTestCase {
  func testRunSimple() {
    let activity = Activity("A Test Activity")

    activity.run {
      let activeIDs = Activity.unsafe.getActiveIDs(max: 16)
      XCTAssertEqual(activeIDs.last, activity.id)
    }
  }

  func testRunResult() {
    let activity = Activity("A Test Activity")

    /// There shoulbe be **NO** `try` required (i.e. ensure "rethrows" not "throws")
    ///
    let x: Int = activity.run {
      let activeIDs = Activity.unsafe.getActiveIDs(max: 16)
      XCTAssertEqual(activeIDs.last, activity.id)
      // Ensure synchronicity of `run`
      Thread.sleep(forTimeInterval: 0.2)
      return 10
    }

    XCTAssertEqual(x, 10)
  }

  func testRunThrows() {
    let activity = Activity("A Test Activity")

    XCTAssertThrowsError(
      try activity.run {
        let activeIDs = Activity.unsafe.getActiveIDs(max: 16)
        XCTAssertEqual(activeIDs.last, activity.id)
        // Ensure synchronicity of `run`
        Thread.sleep(forTimeInterval: 0.2)
        throw URLError(.badURL)
      }
    )
  }

  func testLabel() {
    Activity.labelUserAction("A Unit Test")
  }

  func testImmediate() {
    /// There shoulbe be **NO** `try` required (i.e. ensure "rethrows" not "throws")
    ///
    _ = Activity("A Test Activity") {
      let activeIDs = Activity.unsafe.getActiveIDs(max: 16)
      XCTAssertEqual(activeIDs.count, 1)
    }
  }

  func testImmediateThrows() {
    XCTAssertThrowsError(
      try Activity("A Test Activity") {
        let activeIDs = Activity.unsafe.getActiveIDs(max: 16)
        XCTAssertEqual(activeIDs.count, 1)
        throw URLError(.badURL)
      }
    )
  }

  func testManualScope() {
    func doTest() {
      let activity = Activity("A Test Activity")
      var scope = activity.enter()
      defer { scope.leave() }

      let activeIDs = Activity.unsafe.getActiveIDs(max: 16)
      XCTAssertEqual(activeIDs.last, activity.id)
    }

    // Ensure no current activities
    XCTAssertTrue(Activity.unsafe.getActiveIDs(max: 16).isEmpty)

    doTest()

    // Ensure that `leave` actually left
    XCTAssertTrue(Activity.unsafe.getActiveIDs(max: 16).isEmpty)
  }
}
