//
//  Bool + ObjCBool.swift
//  KDC Parser
//
//  Created by Ky on 2024-02-26.
//

import Foundation



internal extension Bool {
    init(_ objcBool: ObjCBool) {
        self = objcBool.boolValue
    }
}
