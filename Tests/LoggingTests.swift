//
//  LoggingTests.swift
//  OSLogTrace
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import OSLogTrace
import XCTest

class LoggingTests: XCTestCase {
  func testLog() {
    let logging = OSLogManager.for(subsystem: Bundle(for: LoggingTests.self).bundleIdentifier ?? "none")
    let logger = logging.for(category: "Tests")

    let email = ""
    logger.info("Hello \(email, view: .private)")

    logger.log("This is interpolated \(5, type: .default, view: .default)")
    logger.log("This is interpolated \(5, type: .bitrate, view: .default)")
    logger.log("This is interpolated \(5, type: .bytes, view: .default)")
    logger.log("This is interpolated \(5, type: .error, view: .default)")
    logger.log("This is interpolated \(5, type: .time, view: .default)")

    logger.log("This is interpolated \(5, type: .default, view: .private)")
    logger.log("This is interpolated \(5, type: .bitrate, view: .private)")
    logger.log("This is interpolated \(5, type: .bytes, view: .private)")
    logger.log("This is interpolated \(5, type: .error, view: .private)")
    logger.log("This is interpolated \(5, type: .time, view: .private)")

    logger.log("This is interpolated \(5, type: .default, view: .public)")
    logger.log("This is interpolated \(5, type: .bitrate, view: .public)")
    logger.log("This is interpolated \(5, type: .bytes, view: .public)")
    logger.log("This is interpolated \(5, type: .error, view: .public)")
    logger.log("This is interpolated \(5, type: .time, view: .public)")

    logger.log("This is interpolated \(UInt(16), radix: .decimal, view: .default)")
    logger.log("This is interpolated \(UInt(16), radix: .hex, view: .default)")
    logger.log("This is interpolated \(UInt(16), radix: .octal, view: .default)")

    logger.log("This is interpolated \(UInt(16), radix: .decimal, view: .private)")
    logger.log("This is interpolated \(UInt(16), radix: .hex, view: .private)")
    logger.log("This is interpolated \(UInt(16), radix: .octal, view: .private)")

    logger.log("This is interpolated \(UInt(16), radix: .decimal, view: .public)")
    logger.log("This is interpolated \(UInt(16), radix: .hex, view: .public)")
    logger.log("This is interpolated \(UInt(16), radix: .octal, view: .public)")

    logger.log("This is interpolated \(Float(5.1), view: .default)")
    logger.log("This is interpolated \(Float(5.1), view: .private)")
    logger.log("This is interpolated \(Float(5.1), view: .public)")

    logger.log("This is interpolated \(5.2, view: .default)")
    logger.log("This is interpolated \(5.2, view: .private)")
    logger.log("This is interpolated \(5.2, view: .public)")

    logger.log("This is interpolated \(Date(), view: .default)")
    logger.log("This is interpolated \(Date(), view: .private)")
    logger.log("This is interpolated \(Date(), view: .public)")

    logger.log("This is interpolated \(UUID(), view: .public)")

    logger.log("This is interpolated \(UUID.self, view: .public)")

    logger.debug("This is a test")
    logger.info("This is a test")
    logger.log("This is a test")
    logger.error("This is a test")
    logger.fault("This is a test")
  }
}
