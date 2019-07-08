//
//  LinuxMain.swift
//  OSLogTrace
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import XCTest

import OSLogTraceTests

var tests = [XCTestCaseEntry]()
tests += OSLogTraceTests.allTests()
XCTMain(tests)
