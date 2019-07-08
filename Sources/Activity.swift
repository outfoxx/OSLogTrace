//
//  Activity.swift
//  OSLogTrace
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import os.activity

/// An OS activity
///
public struct Activity {
  /// Unique ID of the activity
  public typealias ID = os_activity_id_t

  /// Activity with no current traits.
  ///
  /// When used as a parent activity, it is the equivalent of a passing the `detached` flag.
  ///
  public static let none = Activity(_none)

  /// Represents the  activity of the current thread.
  ///
  /// When used as a parent activity, it links to the current activity if one is present. If no
  /// activity is present it is treated as if it is `detached`.
  ///
  public static let current = Activity(_none)

  /// Options to create activity objects
  ///
  public struct Options: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }

    /// Use the default flags
    public static let `default` = Options(rawValue: OS_ACTIVITY_FLAG_DEFAULT.rawValue)

    /// Detach the newly created activity from the provided activity (if any).  If passed in conjunction with an existing
    /// activity, the activity will only note what activity "created" the new one, but will make the new activity a top
    /// level activity.  This allows users to see what activity triggered work without actually relating the activities.
    public static let detached = Options(rawValue: OS_ACTIVITY_FLAG_DETACHED.rawValue)

    /// Will only create a new activity if none present.  If an activity ID is already present, a new object will be
    /// returned with the same activity ID underneath.
    public static let ifNonePresent = Options(rawValue: OS_ACTIVITY_FLAG_IF_NONE_PRESENT.rawValue)
  }

  /// Returns the ID of the this activity.
  ///
  public var id: ID {
    return os_activity_get_identifier(impl, nil)
  }

  /// Returns the ID of the parent activity.
  ///
  public var parentId: ID {
    var parentId = ID()
    _ = os_activity_get_identifier(impl, &parentId)
    return parentId
  }

  private let impl: OS_os_activity

  /// Initializes a new activity.
  ///
  /// - Parameters:
  ///   - description: Description of the activty.
  ///   - parent: Parent activity of the newly created activity.
  ///   - options: Options of the newly created activity.
  ///
  public init(_ description: StaticString, parent: Activity = .current, options: Options = [], dso: UnsafeRawPointer? = #dsohandle) {
    guard let dso = dso.map({ UnsafeMutableRawPointer(mutating: $0) }) else { fatalError("No DSO handle") }
    impl = description.withUTF8Buffer { ptr in
      ptr.withMemoryRebound(to: Int8.self) { cptr in
        _os_activity_create(dso, cptr.baseAddress!, parent.impl, os_activity_flag_t(rawValue: options.rawValue))
      }
    }
  }

  /// Initializes a new activity and executes a block in its context.
  ///
  /// - Parameters:
  ///   - description: Description of the activty.
  ///   - parent: Parent activity of the newly created activity.
  ///   - options: Options of the newly created activity.
  ///   - block: Block to immediately execute in the activity's context.
  ///
  public init(_ description: StaticString, parent: Activity = .current, options: Options = [], dso: UnsafeRawPointer? = #dsohandle, block: @convention(block) () -> Void) {
    guard let dso = dso.map({ UnsafeMutableRawPointer(mutating: $0) }) else { fatalError("No DSO handle") }
    impl = description.withUTF8Buffer { ptr in
      ptr.withMemoryRebound(to: Int8.self) { cptr in
        _os_activity_create(dso, cptr.baseAddress!, parent.impl, os_activity_flag_t(rawValue: options.rawValue))
      }
    }
    run(block: block)
  }

  /// Initializes a new activity and executes a block in its context.
  ///
  /// - Parameters:
  ///   - description: Description of the activty.
  ///   - parent: Parent activity of the newly created activity.
  ///   - options: Options of the newly created activity.
  ///   - block: Block to immediately execute in the activity's context.
  ///
  public init(_ description: StaticString, parent: Activity = .current, options: Options = [], dso: UnsafeRawPointer? = #dsohandle, block: () throws -> Void) rethrows {
    guard let dso = dso.map({ UnsafeMutableRawPointer(mutating: $0) }) else { fatalError("No DSO handle") }
    impl = description.withUTF8Buffer { ptr in
      ptr.withMemoryRebound(to: Int8.self) { cptr in
        _os_activity_create(dso, cptr.baseAddress!, parent.impl, os_activity_flag_t(rawValue: options.rawValue))
      }
    }
    try run(block: block)
  }

  /// Wraps a previously created activity
  ///
  public init(_ impl: OS_os_activity) {
    self.impl = impl
  }

  /// Executes a block within the context of the activty.
  ///
  /// - Parameters:
  ///   - block: The block to execute
  ///
  public func run(block: @convention(block) () -> Void) {
    os_activity_apply(impl, block)
  }

  /// Executes a block within the context of the activty, optionally returning a value
  /// or throwing errors.
  ///
  /// - Parameters:
  ///   - block: The block to execute
  ///
  public func run<R>(block: () throws -> R) rethrows -> R {
    var result: Result<R, Error>?

    os_activity_apply(impl) {
      do {
        result = .success(try block())
      }
      catch {
        result = .failure(error)
      }
    }

    switch result! {
    case .success(let value): return value
    case .failure(let error): try { throw error }()
    }

    fatalError()
  }

  /// Manual scope manager that allows leaving a previously entered scope at
  /// a specific time.
  ///
  /// - Note: Manually managing a scope is not the preferred method; using
  /// `Activity.run(block:)` will execute a block in an automatically
  /// managed scope.
  ///
  public struct Scope {
    fileprivate var state = os_activity_scope_state_s()

    /// Leaves this scope for the owning activity.
    ///
    public mutating func leave() {
      os_activity_scope_leave(&state)
    }
  }

  /// Creates and automatically enters a scope for the this
  /// activity.
  ///
  /// When manual control of entering and leave an activity scope is rqeuired,
  /// `enter()` can be used to produce a scope and automatically enter it.
  /// The returned `Scope` can  then be used to manually leave the scope
  /// when needed.
  ///
  /// - Note: Manually managing a scope is not the preferred method; using
  /// `run(block:)` will execute a block in an automatically managed scope.
  ///
  /// - Returns: A `Scope` instance controlling the scope created and entered.
  ///
  public func enter() -> Scope {
    var scope = Scope()
    os_activity_scope_enter(impl, &scope.state)
    return scope
  }

  /// Label an activity that is auto-generated by AppKit/UIKit with a name that is
  /// useful for debugging macro-level user actions.
  ///
  /// Label an activity that is auto-generated by AppKit/UIKit with a name that is
  /// useful for debugging macro-level user actions.  The API should be called
  /// early within the scope of the IBAction and before any sub-activities are
  /// created.  The name provided will be shown in tools in additon to the
  /// underlying AppKit/UIKit provided name.  This API can only be called once and
  /// only on the activity created by AppKit/UIKit.  These actions help determine
  /// workflow of the user in order to reproduce problems that occur.  For example,
  /// a control press and/or menu item selection can be labeled:
  ///
  ///     activity.labelUserAction("New mail message")
  ///     activity.labelUserAction("Empty trash")
  ///
  /// Where the underlying AppKit/UIKit name will be "gesture:" or "menuSelect:".
  ///
  /// - Parameters:
  ///   - description A constant string that describes the the action.
  ///
  public static func labelUserAction(_ description: StaticString, dso: UnsafeRawPointer? = #dsohandle) {
    guard let dso = dso.map({ UnsafeMutableRawPointer(mutating: $0) }) else { return }
    description.withUTF8Buffer { ptr in
      ptr.withMemoryRebound(to: Int8.self) { cptr in
        _os_activity_label_useraction(dso, cptr.baseAddress!)
      }
    }
  }

  /// Accesses the "unsafe" interface for activities.
  ///
  /// - Important: The unsafe interface is named as such, and
  /// hidden behind a property, to express its volatile nature
  /// and that its methods and properties may change, disappear
  /// or stop working at any time.
  ///
  /// It is highly suggested that this only be used for debugging
  /// purposes.
  ///
  public static let unsafe: ActivityUnsafe = _ActivityUnsafe()
}

public protocol ActivityUnsafe {
  /// Retrieves the current active ID hierarchy
  ///
  func getActiveIDs(max: Int) -> [Activity.ID]
}

private struct _ActivityUnsafe: ActivityUnsafe {
  @available(macOS, deprecated: 10.12)
  @available(iOS, deprecated: 10)
  @available(tvOS, deprecated: 10)
  @available(watchOS, deprecated: 3)
  func getActiveIDs(max: Int = 16) -> [Activity.ID] {
    var ids = [os_activity_id_t](repeating: 123456, count: max)
    var idCount = UInt32(ids.count)
    os_activity_get_active(&ids, &idCount)
    return Array(ids.prefix(Int(idCount)))
  }
}

private let _none = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_os_activity_none"), to: OS_os_activity.self)
private let _current = unsafeBitCast(dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_os_activity_current"), to: OS_os_activity.self)
