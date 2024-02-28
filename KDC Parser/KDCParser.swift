//
//  main.swift
//  KDC Parser
//
//  Created by Ky on 2024-02-26.
//

import ArgumentParser
import Foundation

import Covfefe



@main
struct KDCParser: ParsableCommand {
    @Argument(parsing: .remaining, help: "The URL to the file to parse", completion: .file(extensions: ["kdc"]))
    var kdcFilePath: String
}



EarleyParser(grammar: .knownDomainCatalog).syntaxTree(for: input)
