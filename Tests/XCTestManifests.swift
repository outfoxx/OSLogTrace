//
//  XCTestManifests.swift
//  OSLogTrace
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    return [
      testCase(OSLogTraceTests.allTests),
    ]
  }
#endif
