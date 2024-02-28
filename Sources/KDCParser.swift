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
    
    /// An error which might occur while reading the input
    enum ReadError: LocalizedError {
        
        /// No input was privided at all (or none could be detected)
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
    
    /// How verbose the output should be
    enum Verbosity: String, CaseIterable, ExpressibleByArgument {
        
        /// Tailor the output Unix-style: Say nothing if things are going well, otherwise only say what went wrong
        case unix
        
        /// Output some appropriate amount of text for the typical usecase.
        ///
        /// Not enough to debug, but more than nothing.
        case `default`
        
        /// Output as much as can be output, usually for debugging purposes
        case verbose
    }
    
    
    
    /// The general behavior desired from this utility
    enum Behavior: String, CaseIterable, ExpressibleByArgument {
        
        /// Just output a "valid" line or error message, along with corresponding exit code, indicating whether this is a valid file
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
    
    /// Finds the user's inputted KDC file and returns the contents, or `nil` if no such file/contents could be found
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
    
    
    /// The URL the user provided for the KDC file to read, or `nil` if the user didn't provide any such URL
    var kdcFileUrl: URL? {
        kdcFilePath.map(URL.init(fileURLWithPath:))
    }
    
    
    /// The path to the KDC file, if any such file path was detected
    var detectedKdcFilePath: String? {
        kdcFilePath ?? remainingPath
    }
    
    
    /// All input from stdin, or `nil` if stdin gave no lines or an empty string
    var stdin: String? {
        var stdinLines = [String]()
        
        while let readFromStdin = readLine(strippingNewline: false) {
            stdinLines.append(readFromStdin)
        }
        
        return stdinLines
                .joined()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .nonEmptyOrNil
    }
}



private extension KDCParser.Behavior {
    
    /// Send the given tree to this behavior for processing
    ///
    /// - Parameter parseTree: The tree to be processed according to this behavior
    func process(_ parseTree: ParseTree) throws {
        switch self {
        case .validate:
            process_validate(parseTree)
        }
    }
    
    
    /// Process according to the `.validate` behavior
    ///
    /// - Parameter parseTree: The tree to be validated
    func process_validate(_ parseTree: ParseTree) {
        log(info: "Valid ✅")
    }
}
