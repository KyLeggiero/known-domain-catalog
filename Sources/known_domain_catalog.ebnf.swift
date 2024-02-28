//
//  known_domain_catalog.ebnf.swift
//  KDC Parser
//
//  Created by Ky on 2024-02-26.
//

import Foundation

import Covfefe



/// The entire EBNF description of KDC, as a string
private let kdc_ebnf = String(bytes: PackageResources.known_domain_catalog_ebnf, encoding: .utf8)!



public extension Grammar {
    
    /// The grammar of KDC-formatted text
    static let knownDomainCatalog = try! Grammar(
        ebnf: kdc_ebnf,
        start: "known_domain_catalog")
}
