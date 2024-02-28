//
//  logging.swift
//
//
//  Created by Ky on 2024-02-27.
//

import Foundation

import SimpleLogging



private extension LogSeverityFilter {
    init(_ verbosity: KDCParser.Verbosity) {
        switch verbosity {
        case .unix:
            self = .specificAndHigher(lowest: .error)
            
        case .default:
            self = .specificAndHigher(lowest: .warning)
            
        case .verbose:
            self = .allowAll
        }
    }
}



internal extension Array where Element == AnyLogChannel {
    init(_ verbosity: KDCParser.Verbosity) {
        switch verbosity {
        case .unix:
            self = [
                LogChannel(name: "kdc_unix", location: .unix, severityFilter: .specificAndHigher(lowest: .error)),
            ]
            
        case .default:
            self = [
                LogChannel(name: "kdc_default", location: .unix, severityFilter: .specificAndHigher(lowest: .info)),
            ]
            
        case .verbose:
            self = [
                LogChannel(name: "kdc_verbose", location: .unix, severityFilter: .allowAll),
            ]
        }
    }
}



private extension CustomRawLogChannelLocation {
    static let unix = Self { message in
        if message.severity < .error {
            print(message.message, to: &kdc.stdout)
        }
        else {
            print(message.message, to: &kdc.stderr)
        }
    }
}



private extension UnreliableLogChannelLocation where Self == CustomRawLogChannelLocation {
    static var unix: Self { CustomRawLogChannelLocation.unix }
}



private var stdout = FileHandle.standardOutput
private var stderr = FileHandle.standardInput
