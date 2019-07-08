# 📒OSLogTrace
## API for Apple's System Log, Signposts and Activty tracing built for Swift
The framework uses features introduced in Swift 5 to make interacting with Apple system log natural and easy from Swift code. Swift
oriented convenience APIs for logging signposts and activity tracing are also included to make their use natural as well.

## Logging

### OSLogManager

The log manager, `OSLogManager`, is a factory to vend configured `OSLog` instances.

Use by calling the static `for` method to create an instance of `OSLogManager`:
```swift
let log = OSLogManager.for(category: "My Application")
```

Further configuration can be achieved by providing a configuration block to alter the manager's properties:
```swift
let logManager = OSLogManager.for(category: "My Application") { logManager in
  logManager.baseCategory = "General"
}
```

`OSLogManager` & `OSLog` provide prefixes that can be used to help identify log messages in complex output. The default values use emoji to 
uniquely identify each log level.  For customization, application-wide configuration of logging prefixes can be done using the global
variable `logConfig`:
```swift
OSLogTrace.logConfig.prefix.error = "☢️"
```

### OSLog

The logging interface uses the standard `OSLog`  class provided by the `os.log` package. It is extended with typed methods for each log level and
take a `LogMessage` to provide parameterized logging messages using Swift 5's string interpolation magic.

```swift
extension OSLog {
  public func log(type: OSLogType, _ message: @autoclosure () -> LogMessage)
  public func log(_ message: @autoclosure () -> LogMessage) 
  public func info(_ message: @autoclosure () -> LogMessage)
  public func debug(_ message: @autoclosure () -> LogMessage)
  public func error(_ message: @autoclosure () -> LogMessage)
  public func fault(_ message: @autoclosure () -> LogMessage)
}
```

### LogMessage

Generating parameterized log messages is simple using `LogMessage` and thanks to Swift 5's string interpolation support
(via `ExpressibleByStringInterpolation`) they can be created using standard Swift syntax...

```swift
let audience = "World"
log.info("Hello \(audience)")
```

This simple log message properly passes the `audience` parameter on to the `OSLog` as a _dynamic parameter_. This defers
message creation until needed and allows us to control how the system log displays and reports these parameters.

##### Display

Apple's system log can interpret certain types of data and OSLogTrace's logging extensions expose that capability naturally.

For example, if you are logging download progress you might use:
```swift
let completedBytes = 2.4 * 1024 * 1024
log.debug("Downloaded \(completedBytes, unit: .bytes)")
```

The log will display the value using the best available unit. In this specfic case it would be reported as:
    
    Downloaded 2.4 MiB 

##### Privacy

Apple's System Log supports privacy as well.  Marking parameters as `private` will ensure this information is not stored long term and redacted in
the right context.

For example, logging a sign-in that contains a private email address is simple:
```swift
let accountEmail = "test@example.com"
log.info("Sign-in from \(accountEmail, view: .private)")
```

The system log will now take care of handling the sensitive email data.

For more information see "Formmatting Log Messages" in
[Apple's Logging documentation](https://developer.apple.com/documentation/os/logging#topics)

### Signposts

Signpost's are Apple's logging enhancement for debugging and profiling working side-by-side with `OSLog`. Signpost IDs can be
created and marked using OSLogTrace's convenience API(s).

Create a signpost ID unique to a specific log instance, and mark it:
```swift
let log: OSLog = ...
let spid = log.signpostID()  // Create ID
log.event("Stage 1", spid)   // Mark "event"
log.event("Stage 1", spid, "A \(parameterized) message") // Mark "event" with a log message
```

Utilize the `Signpost` convenience API to manage a signpost ID and log together:
```swift
let log: OSLog = ...
let sp = log.signpost()   // Create a Signpost with a unique signpost ID
sp.event("Stage 1")       // Mark "event"
sp.event("Stage 1", "A \(parameterized) message") // Mark "event" with a log message
```


## Activity Tracing

OSLogTrace also provides a convenience API for Apple's activity tracing.

Create an `Activity` and immediately execute code in its context:
```swift
Activity("Download Email") {
  // download the emails
}
```

Create an `Activity` and execute multiple code blocks in its context:
```swift
let emailDownload = Activity("Download Email")

emailDownload.run {
  // download some emails
}

...

emailDownload.run {
  // download some emails
}
```

Create an `Activity` and manually manage the entering and leaving of its scope/context:
```swift
let emailDownload = Activity("Download Email")

let scope = emailDownload.enter()
defer { scope.leave() }

// download some emails
```
