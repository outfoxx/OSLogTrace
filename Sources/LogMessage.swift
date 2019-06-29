//
//  LogMessage.swift
//  OSLogTrace
//
//  Created by Kevin Wooten on 6/5/19.
//  Copyright © 2019 Outfox, Inc. All rights reserved.
//

import Foundation
import os
import os.log
import _SwiftOSOverlayShims

#if os(iOS) || os(tvOS) || os(watchOS)
import CoreGraphics
#endif


public enum LogArgumentType : String {
  case bytes = "iec-bytes"
  case bitrate = "iec-bitrate"
  case time = "time_t"
  case error = "errno"
  case `default` = ""
}

public enum LogArgumentView : String {
  case `public` = "public"
  case `private` = "private"
  case `default` = ""
}

public enum LogArgumentRadix : String {
  case decimal = "u"
  case octal = "o"
  case hex = "x"
}

public struct LogMessage: ExpressibleByStringInterpolation {


  public struct StringInterpolation: StringInterpolationProtocol {
    var format = ""
    var arguments: [CVarArg] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
      format.reserveCapacity(literalCapacity + (interpolationCount * 10))
      arguments.reserveCapacity(interpolationCount)
    }

    public mutating func appendLiteral(_ literal: String) {
      format += literal
    }

    public mutating func appendInterpolation<T>(_ value: T?, view: LogArgumentView = .default) {
      guard let value = value else { format += "<nil>"; return }
      format += "%\(spec(view: view))s"
      arguments.append(String(describing: value))
    }

    public mutating func appendInterpolation<N>(_ value: N?, view: LogArgumentView = .default) where N : NSObjectProtocol & CVarArg {
      guard let value = value else { format += "<nil>"; return }
      format += "%\(spec(view: view))@"
      arguments.append(value)
    }

    public mutating func appendInterpolation<S>(_ value: S?, view: LogArgumentView = .default) where S : StringProtocol & CVarArg {
      guard let value = value else { format += "<nil>"; return }
      format += "%\(spec(view: view))s"
      arguments.append(value)
    }

    public mutating func appendInterpolation<F>(_ value: F?, view: LogArgumentView = .default) where F : BinaryFloatingPoint & CVarArg {
      guard let value = value else { format += "<nil>"; return }
      format += "%\(spec(view: view))\(prefix(value))g"
      arguments.append(value)
    }

    public mutating func appendInterpolation<SI>(_ value: SI?, type: LogArgumentType = .default, view: LogArgumentView = .default) where SI : SignedInteger & CVarArg {
      guard let value = value else { format += "<nil>"; return }
      format += "%\(spec(view: view, type: type))\(prefix(value))d"
      arguments.append(value)
    }

    public mutating func appendInterpolation<UI>(_ value: UI?, radix: LogArgumentRadix, view: LogArgumentView = .default) where UI : UnsignedInteger & CVarArg {
      guard let value = value else { format += "<nil>"; return }
      format += "%\(spec(view: view))\(prefix(value))\(radix.rawValue)"
      arguments.append(value)
    }

    public mutating func appendInterpolation(_ value: Date?, view: LogArgumentView = .default) {
      guard let value = value else { format += "<nil>"; return }
      format += "%{time_t}d"
      arguments.append(Int(value.timeIntervalSince1970))
    }

    public mutating func appendInterpolation(_ value: UUID?, view: LogArgumentView = .default) {
      guard let value = value else { format += "<nil>"; return }
      format += "%s"
      arguments.append(value.uuidString)
    }

  }

  let interpolation: StringInterpolation

  public init(stringLiteral value: StringLiteralType) {
    var interpolation = StringInterpolation(literalCapacity: 0, interpolationCount: 0)
    interpolation.appendLiteral(value)
    self.interpolation = interpolation
  }

  public init(stringInterpolation: StringInterpolation) {
    self.interpolation = stringInterpolation
  }

  public func log(type: OSLogType, log: OSLog, prefix: String, dso: UnsafeRawPointer = #dsohandle) {
    let ra = _swift_os_log_return_address()
    "\(prefix)\(interpolation.format)".withCString { str in
      withVaList(interpolation.arguments) { args in
        _swift_os_log(dso, ra, log, .default, str, args)
      }
    }
  }

}

private func spec(view: LogArgumentView = .default, type: LogArgumentType = .default) -> String {
  switch (view, type) {
  case (.default, .default): return ""
  case (.default, _): return "{\(type.rawValue)}"
  case (_, .default): return "{\(view.rawValue)}"
  default: return "{\(view.rawValue),\(type.rawValue)}"
  }
}

let intPrefixes = ["hh", "h", "l", "ll"]
let floatPrefixes = ["", "", "L"]

func prefix<T : BinaryInteger>(_ value: T) -> String { return intPrefixes[MemoryLayout<T>.size/8] }
func prefix<T : BinaryFloatingPoint>(_ value: T) -> String { return floatPrefixes[Int(ceil(Double(MemoryLayout<T>.size)/32.0))] }
