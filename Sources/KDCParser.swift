//
//  KDCParser.swift
//  KDC Parser
//
//  Created by Ky on 2024-02-26.
//

import ArgumentParser
import Foundation

import CollectionTools
import Covfefe
import SimpleLogging



@main
struct KDCParser: ParsableCommand {
    @Option(name: .customLong("input"),
            help: "The path to the KDC file to parse",
            completion: .file(extensions: ["kdc"]))
    var kdcFilePath: String?
    
    @Option(help: "How verbose to make the output. Set to `unix` to only output error messages.")
    var verbosity: Verbosity = .default
    
    @Option(help: .init("The general behavior you want from this utility.", discussion: ""))
    var behavior: Behavior = .validate
    
    @Argument(help: .hidden,
              completion: .file(extensions: ["kdc"]))
    var remainingPath: String?
    
    
    func run() throws {
        LogManager.defaultChannels = .init(verbosity)
        
        guard let input else {
            throw ReadError.noInputGiven
        }
        
        let syntaxTree = try EarleyParser(grammar: .knownDomainCatalog).syntaxTree(for: input + "\n")
        
        try behavior.process(syntaxTree)
    }
    
    
    static let configuration = CommandConfiguration(
        commandName: "kdc",
        abstract: """
            This command parses Known Database Catalogs and outputs the catalog contents as another format, or simply exits with an exit code.
            """,
        
        discussion: """
            You may omit the `--input` option, but only if you then provide a URL at the end of the argument list, or send the KDC file contents directly to stdin.
            
            This command outputs a `0` exit code for success, or nonzero exit codes for failures.
            """,
        
        version: "1.2.0-alpha.12"
    )
}



// MARK: - Errors

extension KDCParser {
    enum ReadError: LocalizedError {
        
        case noInputGiven
        
        
        var errorDescription: String? {
            switch self {
            case .noInputGiven:
                "You need to provide an input. Use --help to see available ways to do this."
            }
        }
    }
}



// MARK: - Input types

extension KDCParser {
    
    enum Verbosity: String, CaseIterable, ExpressibleByArgument {
        case unix
        case `default`
        case verbose
    }
    
    
    
    /// The general behavior desired from this utility
    enum Behavior: String, CaseIterable, ExpressibleByArgument {
        
        /// Just output a "pass" or "fail" line, along with corresponding exit code, indicating whether this is a valid file
        case validate
        
//        case convert(outputFormat: OutputFormat)
//        
//        
//        
//        enum OutputFormat {
//            case json
//            case xml
//        }
    }
}



// MARK: - Helpers

private extension KDCParser {
    
    var input: String? {
        
        func _read(fromFileAt fileUrl: URL) throws -> String? {
            let fileUrl = fileUrl.resolvingSymlinksInPath().standardizedFileURL.absoluteURL
            let filePath = fileUrl.path
            let fileManager = FileManager.default
            
            var isDirectory: ObjCBool = true
            
            guard fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory),
                  !Bool(isDirectory)
            else {
                return nil
            }
            
            return try String(contentsOfFile: filePath)
        }
        
        
        if let kdcFileUrl {
            return log(errorIfThrows: try _read(fromFileAt: kdcFileUrl), backup: nil)
        }
        else if let stdin {
            if FileManager.default.fileExists(atPath: stdin) {
                return log(errorIfThrows: try _read(fromFileAt: URL(fileURLWithPath: stdin)), backup: nil)
            }
            else {
                return stdin
            }
        }
        else {
            return nil
        }
    }
    
    
    var kdcFileUrl: URL? {
        kdcFilePath.map(URL.init(fileURLWithPath:))
    }
    
    
    var detectedKdcFilePath: String? {
        return if let kdcFilePath {
            kdcFilePath
        }
        else if let remainingPath {
            remainingPath
        }
        else {
            nil
        }
    }
    
    
    var stdin: String? {
        var stdinLines = [String]()
        
        while let readFromStdin = readLine(strippingNewline: false) {
            stdinLines.append(readFromStdin)
        }
        
        return stdinLines.isEmpty
            ? nil
            : stdinLines
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .nonEmptyOrNil
    }
}



private extension KDCParser.Behavior {
    func process(_ parseTree: ParseTree) throws {
        switch self {
        case .validate:
            process_validate(parseTree)
        }
    }
    
    
    func process_validate(_ parseTree: ParseTree) {
        log(info: "Valid ✅")
    }
}
