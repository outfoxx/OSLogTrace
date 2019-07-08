//
//  Logging.swift
//  OSLogTrace
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import _SwiftOSOverlayShims
import Foundation
import os
@_exported import os.log

public struct OSLogManager {
  public var subsystem: String
  public var baseCategory: String?

  public func `for`(category: String? = nil) -> OSLog {
    let fullCategory: String
    switch (category, baseCategory) {
    case (nil, nil):
      fullCategory = ""
    case (_, nil):
      fullCategory = category!
    case (nil, _):
      fullCategory = baseCategory!
    default:
      fullCategory = "\(baseCategory!).\(category!)"
    }

    return OSLog(subsystem: subsystem, category: fullCategory)
  }

  fileprivate init(subsystem: String, baseCategory: String? = nil) {
    self.subsystem = subsystem
    self.baseCategory = baseCategory
  }
}

extension OSLogManager {
  public static func `for`(subsystem: String, baseCategory: String? = nil, configurator: (OSLogManager) -> Void = { _ in }) -> OSLogManager {
    let logManager = OSLogManager(subsystem: subsystem, baseCategory: baseCategory)
    configurator(logManager)
    return logManager
  }
}

public struct OSLogConfig {
  public struct Prefixes {
    public var debug = "⚫️ "
    public var info = "🔵 "
    public var `default` = "💬 "
    public var error = "⚠️ "
    public var fault = "⛔️ "

    public func prefix(for type: OSLogType) -> String {
      switch type {
      case .debug: return debug
      case .info: return info
      case .default: return `default`
      case .error: return error
      case .fault: return fault
      default:
        fatalError()
      }
    }
  }

  public var prefixes = Prefixes()
}

public var logConfig = OSLogConfig()

extension OSLog {
  @inline(__always)
  public func log(_ message: @autoclosure () -> LogMessage) {
    guard isEnabled(type: .default) else { return }
    message().log(type: .default, log: self, prefix: logConfig.prefixes.default)
  }

  @inline(__always)
  public func log(type: OSLogType, _ message: @autoclosure () -> LogMessage) {
    guard isEnabled(type: .default) else { return }
    message().log(type: type, log: self, prefix: logConfig.prefixes.default)
  }

  @inline(__always)
  public func info(_ message: @autoclosure () -> LogMessage) {
    guard isEnabled(type: .info) else { return }
    message().log(type: .info, log: self, prefix: logConfig.prefixes.info)
  }

  @inline(__always)
  public func debug(_ message: @autoclosure () -> LogMessage) {
    guard isEnabled(type: .debug) else { return }
    message().log(type: .debug, log: self, prefix: logConfig.prefixes.debug)
  }

  @inline(__always)
  public func error(_ message: @autoclosure () -> LogMessage) {
    guard isEnabled(type: .error) else { return }
    message().log(type: .error, log: self, prefix: logConfig.prefixes.error)
  }

  @inline(__always)
  public func fault(_ message: @autoclosure () -> LogMessage) {
    guard isEnabled(type: .fault) else { return }
    message().log(type: .fault, log: self, prefix: logConfig.prefixes.fault)
  }
}
