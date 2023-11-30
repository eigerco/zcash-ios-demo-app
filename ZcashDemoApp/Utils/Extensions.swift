//
//  Extensions.swift
//  ZcashDemoApp
//
//  Created by Luca Campobasso on 27/11/2023.
//

import Foundation

// Simulates StringBuilder from kotlin
extension String {
    mutating func appendLine(_ value: String) {
        append(String(format: "%@\n", value))
    }

    mutating func appendLine(_ key: String, _ value: String) {
        append(String(format: "%@:%@\n", key, value))
    }

    mutating func appendNumber(_ key: String, _ value: UInt32) {
        append(String(format: "%@: %i\n", key, value))
    }

    mutating func appendNumber(_ key: String, _ value: UInt64) {
        append(String(format: "%@: %i\n", key, value))
    }

    mutating func appendNumber(_ key: String, _ value: Int) {
        append(String(format: "%@: %i\n", key, value))
    }
    
    func encodeAsZcashTransactionMemo() -> Data? {
        data(using: .utf8)
    }
    
    func toTxIdString() -> String {
        var id = ""
        self.reversed().pairs
            .map {
                $0.reversed()
            }
            .forEach { reversed in
                id.append(String(reversed))
            }
        return id
    }
}


extension Data {
    init?(fromHexEncodedString string: String) {
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(bytes: UInt16) -> UInt8? {
            switch bytes {
            case 0x30 ... 0x39:
                UInt8(bytes - 0x30)
            case 0x41 ... 0x46:
                UInt8(bytes - 0x41 + 10)
            case 0x61 ... 0x66:
                UInt8(bytes - 0x61 + 10)
            default:
                nil
            }
        }

        self.init(capacity: string.utf16.count / 2)
        var even = true
        var byte: UInt8 = 0
        for char in string.utf16 {
            guard let val = decodeNibble(bytes: char) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                append(byte)
            }
            even.toggle()
        }
        guard even else { return nil }
    }
    
    func asZcashTransactionMemo() -> String? {
        String(data: self, encoding: .utf8)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        z_hexEncodedString(data: self, options: options)
    }
}

struct HexEncodingOptions: OptionSet {
    public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

func z_hexEncodedString(data: Data, options: HexEncodingOptions = []) -> String {
    let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
    var chars: [unichar] = []

    chars.reserveCapacity(2 * data.count)
    for byte in data {
        chars.append(hexDigits[Int(byte / 16)])
        chars.append(hexDigits[Int(byte % 16)])
    }

    return String(utf16CodeUnits: chars, count: chars.count)
}

extension Collection {
    var pairs: [SubSequence] {
        var startIndex = self.startIndex
        let count = self.count
        let halving = count / 2 + count % 2
        return (0..<halving).map { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return self[startIndex..<endIndex]
        }
    }
}
