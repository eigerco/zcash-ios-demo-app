//
//  Directories.swift
//  ZcashDemoApp
//
//  Created by Luca Campobasso on 21/11/2023.
//

import Foundation

enum Directories {
    static let walletDbName = "WalletDatabase.db"

    static func documentsDirectoryHelper() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    static func dataDbURLHelper() throws -> URL {
        try documentsDirectoryHelper().appendingPathComponent(walletDbName, isDirectory: false)
    }

    static func spendParamsURLHelper() throws -> URL {
        try documentsDirectoryHelper().appendingPathComponent("sapling-spend.params")
    }

    static func outputParamsURLHelper() throws -> URL {
        try documentsDirectoryHelper().appendingPathComponent("sapling-output.params")
    }
}
