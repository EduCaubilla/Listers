import CocoaLumberjackSwift

public class LoggingService {
    public static let shared = LoggingService()

    private let fileLogger: DDFileLogger

    private init() {
        // A logger that sends messages to the OSLog system (viewable in Console.app)
        DDLog.add(DDOSLogger.sharedInstance)

        // A logger that writes to a file
        fileLogger = DDFileLogger()

        // Configure the file logger
        fileLogger.rollingFrequency = 60 * 60 * 24  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 8 // Keep logs for 8 days

        // Add the file logger to the system
        DDLog.add(fileLogger)
        
        DDLogInfo("LoggingService initialized.")
        DDLogInfo("Log file path: '\(fileLogger.logFileManager.logsDirectory)'")
    }

    public func setup() {
        // This is just a placeholder to ensure the singleton is initialized.
    }
}
