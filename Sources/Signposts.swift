//
//  Signposts.swift
//  
//
//  Created by Kevin Wooten on 7/8/19.
//

import Foundation
import os
@_exported import os.log
import _SwiftOSOverlayShims


@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
public extension OSLog {

  /// Creates a signpost ID unique to the this log instance.
  ///
  /// - Returns: A signpost ID unique to this log instance.
  ///
  func signpostID() -> OSSignpostID {
    return OSSignpostID(log: self)
  }

  /// Creates a signpost ID unique to this log instance as well as the `object`.
  ///
  /// - Parameters:
  ///   - object: An object to further make the signpost unique to.
  /// - Returns: A signpost ID unique to this log instance as well as the `object`.
  ///
  func signpostID(object: AnyObject) -> OSSignpostID {
    return OSSignpostID(log: self, object: object)
  }

  /// Creates a signpost manager using the provided ID.
  ///
  /// The signpost managed allows easy marking of signpost events using this log
  /// instance and the provided signpost ID.
  ///
  /// - Parameters:
  ///   - id: Signpost ID to create a manager for.
  /// - Returns: A signpost manager bound to this log instance and the `id`.
  ///
  func signpost(id: OSSignpostID, dso: UnsafeRawPointer = #dsohandle) -> OSSignpost {
    return OSSignpost(log: self, id: id)
  }

  /// Creates a signpost manager using a generated unique signpost ID.
  ///
  /// The signpost managed allows easy marking of signpost events using this log
  /// instance and the provided signpost ID.
  ///
  /// - Parameters:
  ///   - object: (optional) An object to further make the unique ID. See `OSLogTrace.signpostID(object:)`
  /// - Returns: A signpost manager bound to this log instance and the `id`
  ///
  func signpost(object: AnyObject? = nil, dso: UnsafeRawPointer = #dsohandle) -> OSSignpost {
    if let object = object {
      return OSSignpost(log: self, id: signpostID(object: object))
    }
    return OSSignpost(log: self, id: signpostID())
  }

  /// Marks a signpost with the provided type.
  ///
  /// - Parameters:
  ///   - type: Signpost type (evemt, begin, end)
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///
  func mark(_ type: OSSignpostType, name: String, id: OSSignpostID, dso: UnsafeRawPointer = #dsohandle) {
    _mark(type, in: self, id: id, name: name, dso: dso)
  }

  /// Marks a signpost with the provided type and a message.
  ///
  /// - Parameters:
  ///   - type: Signpost type (evemt, begin, end)
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///   - message: Formatted log message
  ///
  func mark(_ type: OSSignpostType, name: String, id: OSSignpostID, message:  @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(type, in: self, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

  /// Marks a signpost `event`.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///
  func event(name: String, id: OSSignpostID, dso: UnsafeRawPointer = #dsohandle) {
    _mark(.event, in: self, id: id, name: name, dso: dso)
  }

  /// Marks a signpost `event` with a log message.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///   - message: Formatted log message
  ///
  func event(name: String, id: OSSignpostID, message: @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(.event, in: self, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

  /// Marks a signpost `begin`.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///
  func begin(name: String, id: OSSignpostID, dso: UnsafeRawPointer = #dsohandle) {
    _mark(.begin, in: self, id: id, name: name, dso: dso)
  }

  /// Marks a signpost `begin` with a log message.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///   - message: Formatted log message
  ///
  func begin(name: String, id: OSSignpostID, message: @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(.begin, in: self, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

  /// Marks a signpost `end`.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///
  func end(name: String, id: OSSignpostID, dso: UnsafeRawPointer = #dsohandle) {
    _mark(.end, in: self, id: id, name: name, dso: dso)
  }

  /// Marks a signpost `end` with a log message.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - id: ID of the signpost
  ///   - message: Formatted log message
  ///
  func end(name: String, id: OSSignpostID, message: @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(.end, in: self, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

}

/// Signpost manager for convenient marking of signposts to a specific log and with a specific ID.
///
@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
public struct OSSignpost {

  public let log: OSLog
  public let id: OSSignpostID

  public init(log: OSLog, id: OSSignpostID) {
    self.log = log
    self.id = id
  }

  /// Marks a signpost event of the provided type.
  ///
  /// - Parameters:
  ///   - type: Signpost type (evemt, begin, end)
  ///   - name: Name of signpost event
  ///
  public func mark(_ type: OSSignpostType, name: String, dso: UnsafeRawPointer = #dsohandle) {
    _mark(type, in: log, id: id, name: name, dso: dso)
  }

  /// Marks a signpost event of the provided type with a log message.
  ///
  /// - Parameters:
  ///   - type: Signpost type (evemt, begin, end)
  ///   - name: Name of signpost event
  ///   - message: Formatted log message
  ///
  public func mark(_ type: OSSignpostType, name: String, message:  @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(type, in: log, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

  /// Marks a signpost `event` with a log message.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///
  public func event(name: String, dso: UnsafeRawPointer = #dsohandle) {
    _mark(.event, in: log, id: id, name: name, dso: dso)
  }

  /// Marks a signpost `event`.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - message: Formatted log message
  ///
  public func event(name: String, message: @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(.event, in: log, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

  /// Marks a signpost `begin`.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///
  public func begin(name: String, dso: UnsafeRawPointer = #dsohandle) {
    _mark(.begin, in: log, id: id, name: name, dso: dso)
  }

  /// Marks a signpost `begin` with a log message.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - message: Formatted log message
  ///
  public func begin(name: String, message: @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(.begin, in: log, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

  /// Marks a signpost `end`.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///
  public func end(name: String, dso: UnsafeRawPointer = #dsohandle) {
    _mark(.end, in: log, id: id, name: name, dso: dso)
  }

  /// Marks a signpost `end` with a log message.
  ///
  /// - Parameters:
  ///   - name: Name of signpost event
  ///   - message: Formatted log message
  ///
  public func end(name: String, message: @autoclosure () -> LogMessage, dso: UnsafeRawPointer = #dsohandle) {
    let message = message()
    _mark(.end, in: log, id: id, name: name,
          format: message.interpolation.format, formatArgs: message.interpolation.arguments, dso: dso)
  }

}


@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
fileprivate func _mark(_ type: OSSignpostType, in log: OSLog, id: OSSignpostID, name: String, dso: UnsafeRawPointer) {
  let ra = _swift_os_log_return_address()
  name.withCString { namePtr in
    _swift_os_signpost(dso, ra, log, type, namePtr, id.rawValue)
  }
}


@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
fileprivate func _mark(_ type: OSSignpostType, in log: OSLog, id: OSSignpostID, name: String, format: String, formatArgs: [CVarArg], dso: UnsafeRawPointer) {
  let ra = _swift_os_log_return_address()
  name.withCString { namePtr in
    format.withCString { formatPtr in
      withVaList(formatArgs) { formatArgs in
        _swift_os_signpost_with_format(dso, ra, log, type, namePtr, id.rawValue, formatPtr, formatArgs)
      }
    }
  }
}
