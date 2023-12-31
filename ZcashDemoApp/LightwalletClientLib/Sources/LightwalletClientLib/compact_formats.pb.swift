// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: compact_formats.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Copyright (c) 2019-2021 The Zcash developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or https://www.opensource.org/licenses/mit-license.php .

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

/// ChainMetadata represents information about the state of the chain as of a given block.
public struct ChainMetadata {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// the size of the Sapling note commitment tree as of the end of this block
    public var saplingCommitmentTreeSize: UInt32 = 0

    /// the size of the Orchard note commitment tree as of the end of this block
    public var orchardCommitmentTreeSize: UInt32 = 0

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

/// CompactBlock is a packaging of ONLY the data from a block that's needed to:
///   1. Detect a payment to your shielded Sapling address
///   2. Detect a spend of your shielded Sapling notes
///   3. Update your witnesses to generate new Sapling spend proofs.
public struct CompactBlock {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// the version of this wire format, for storage
    public var protoVersion: UInt32 = 0

    /// the height of this block
    public var height: UInt64 = 0

    /// the ID (hash) of this block, same as in block explorers
    public var hash: Data = .init()

    /// the ID (hash) of this block's predecessor
    public var prevHash: Data = .init()

    /// Unix epoch time when the block was mined
    public var time: UInt32 = 0

    /// (hash, prevHash, and time) OR (full header)
    public var header: Data = .init()

    /// zero or more compact transactions from this block
    public var vtx: [CompactTx] = []

    /// information about the state of the chain as of this block
    public var chainMetadata: ChainMetadata {
        get { _chainMetadata ?? ChainMetadata() }
        set { _chainMetadata = newValue }
    }

    /// Returns true if `chainMetadata` has been explicitly set.
    public var hasChainMetadata: Bool { _chainMetadata != nil }
    /// Clears the value of `chainMetadata`. Subsequent reads from it will return its default value.
    public mutating func clearChainMetadata() { _chainMetadata = nil }

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}

    fileprivate var _chainMetadata: ChainMetadata?
}

/// CompactTx contains the minimum information for a wallet to know if this transaction
/// is relevant to it (either pays to it or spends from it) via shielded elements
/// only. This message will not encode a transparent-to-transparent transaction.
public struct CompactTx {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Index and hash will allow the receiver to call out to chain
    /// explorers or other data structures to retrieve more information
    /// about this transaction.
    public var index: UInt64 = 0

    /// the ID (hash) of this transaction, same as in block explorers
    public var hash: Data = .init()

    /// The transaction fee: present if server can provide. In the case of a
    /// stateless server and a transaction with transparent inputs, this will be
    /// unset because the calculation requires reference to prior transactions.
    /// If there are no transparent inputs, the fee will be calculable as:
    ///    valueBalanceSapling + valueBalanceOrchard + sum(vPubNew) - sum(vPubOld) - sum(tOut)
    public var fee: UInt32 = 0

    public var spends: [CompactSaplingSpend] = []

    public var outputs: [CompactSaplingOutput] = []

    public var actions: [CompactOrchardAction] = []

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

/// CompactSaplingSpend is a Sapling Spend Description as described in 7.3 of the Zcash
/// protocol specification.
public struct CompactSaplingSpend {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// nullifier (see the Zcash protocol specification)
    public var nf: Data = .init()

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

/// output encodes the `cmu` field, `ephemeralKey` field, and a 52-byte prefix of the
/// `encCiphertext` field of a Sapling Output Description. These fields are described in
/// section 7.4 of the Zcash protocol spec:
/// https://zips.z.cash/protocol/protocol.pdf#outputencodingandconsensus
/// Total size is 116 bytes.
public struct CompactSaplingOutput {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// note commitment u-coordinate
    public var cmu: Data = .init()

    /// ephemeral public key
    public var ephemeralKey: Data = .init()

    /// first 52 bytes of ciphertext
    public var ciphertext: Data = .init()

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

/// https://github.com/zcash/zips/blob/main/zip-0225.rst#orchard-action-description-orchardaction
/// (but not all fields are needed)
public struct CompactOrchardAction {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// [32] The nullifier of the input note
    public var nullifier: Data = .init()

    /// [32] The x-coordinate of the note commitment for the output note
    public var cmx: Data = .init()

    /// [32] An encoding of an ephemeral Pallas public key
    public var ephemeralKey: Data = .init()

    /// [52] The first 52 bytes of the encCiphertext field
    public var ciphertext: Data = .init()

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
    extension ChainMetadata: @unchecked Sendable {}
    extension CompactBlock: @unchecked Sendable {}
    extension CompactTx: @unchecked Sendable {}
    extension CompactSaplingSpend: @unchecked Sendable {}
    extension CompactSaplingOutput: @unchecked Sendable {}
    extension CompactOrchardAction: @unchecked Sendable {}
#endif // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "cash.z.wallet.sdk.rpc"

extension ChainMetadata: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".ChainMetadata"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "saplingCommitmentTreeSize"),
        2: .same(proto: "orchardCommitmentTreeSize"),
    ]

    public mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch fieldNumber {
            case 1: try decoder.decodeSingularUInt32Field(value: &saplingCommitmentTreeSize)
            case 2: try decoder.decodeSingularUInt32Field(value: &orchardCommitmentTreeSize)
            default: break
            }
        }
    }

    public func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
        if saplingCommitmentTreeSize != 0 {
            try visitor.visitSingularUInt32Field(value: saplingCommitmentTreeSize, fieldNumber: 1)
        }
        if orchardCommitmentTreeSize != 0 {
            try visitor.visitSingularUInt32Field(value: orchardCommitmentTreeSize, fieldNumber: 2)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: ChainMetadata, rhs: ChainMetadata) -> Bool {
        if lhs.saplingCommitmentTreeSize != rhs.saplingCommitmentTreeSize { return false }
        if lhs.orchardCommitmentTreeSize != rhs.orchardCommitmentTreeSize { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension CompactBlock: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".CompactBlock"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "protoVersion"),
        2: .same(proto: "height"),
        3: .same(proto: "hash"),
        4: .same(proto: "prevHash"),
        5: .same(proto: "time"),
        6: .same(proto: "header"),
        7: .same(proto: "vtx"),
        8: .same(proto: "chainMetadata"),
    ]

    public mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch fieldNumber {
            case 1: try decoder.decodeSingularUInt32Field(value: &protoVersion)
            case 2: try decoder.decodeSingularUInt64Field(value: &height)
            case 3: try decoder.decodeSingularBytesField(value: &hash)
            case 4: try decoder.decodeSingularBytesField(value: &prevHash)
            case 5: try decoder.decodeSingularUInt32Field(value: &time)
            case 6: try decoder.decodeSingularBytesField(value: &header)
            case 7: try decoder.decodeRepeatedMessageField(value: &vtx)
            case 8: try decoder.decodeSingularMessageField(value: &_chainMetadata)
            default: break
            }
        }
    }

    public func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every if/case branch local when no optimizations
        // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
        // https://github.com/apple/swift-protobuf/issues/1182
        if protoVersion != 0 {
            try visitor.visitSingularUInt32Field(value: protoVersion, fieldNumber: 1)
        }
        if height != 0 {
            try visitor.visitSingularUInt64Field(value: height, fieldNumber: 2)
        }
        if !hash.isEmpty {
            try visitor.visitSingularBytesField(value: hash, fieldNumber: 3)
        }
        if !prevHash.isEmpty {
            try visitor.visitSingularBytesField(value: prevHash, fieldNumber: 4)
        }
        if time != 0 {
            try visitor.visitSingularUInt32Field(value: time, fieldNumber: 5)
        }
        if !header.isEmpty {
            try visitor.visitSingularBytesField(value: header, fieldNumber: 6)
        }
        if !vtx.isEmpty {
            try visitor.visitRepeatedMessageField(value: vtx, fieldNumber: 7)
        }
        try { if let v = self._chainMetadata {
            try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
        } }()
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: CompactBlock, rhs: CompactBlock) -> Bool {
        if lhs.protoVersion != rhs.protoVersion { return false }
        if lhs.height != rhs.height { return false }
        if lhs.hash != rhs.hash { return false }
        if lhs.prevHash != rhs.prevHash { return false }
        if lhs.time != rhs.time { return false }
        if lhs.header != rhs.header { return false }
        if lhs.vtx != rhs.vtx { return false }
        if lhs._chainMetadata != rhs._chainMetadata { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension CompactTx: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".CompactTx"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "index"),
        2: .same(proto: "hash"),
        3: .same(proto: "fee"),
        4: .same(proto: "spends"),
        5: .same(proto: "outputs"),
        6: .same(proto: "actions"),
    ]

    public mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch fieldNumber {
            case 1: try decoder.decodeSingularUInt64Field(value: &index)
            case 2: try decoder.decodeSingularBytesField(value: &hash)
            case 3: try decoder.decodeSingularUInt32Field(value: &fee)
            case 4: try decoder.decodeRepeatedMessageField(value: &spends)
            case 5: try decoder.decodeRepeatedMessageField(value: &outputs)
            case 6: try decoder.decodeRepeatedMessageField(value: &actions)
            default: break
            }
        }
    }

    public func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
        if index != 0 {
            try visitor.visitSingularUInt64Field(value: index, fieldNumber: 1)
        }
        if !hash.isEmpty {
            try visitor.visitSingularBytesField(value: hash, fieldNumber: 2)
        }
        if fee != 0 {
            try visitor.visitSingularUInt32Field(value: fee, fieldNumber: 3)
        }
        if !spends.isEmpty {
            try visitor.visitRepeatedMessageField(value: spends, fieldNumber: 4)
        }
        if !outputs.isEmpty {
            try visitor.visitRepeatedMessageField(value: outputs, fieldNumber: 5)
        }
        if !actions.isEmpty {
            try visitor.visitRepeatedMessageField(value: actions, fieldNumber: 6)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: CompactTx, rhs: CompactTx) -> Bool {
        if lhs.index != rhs.index { return false }
        if lhs.hash != rhs.hash { return false }
        if lhs.fee != rhs.fee { return false }
        if lhs.spends != rhs.spends { return false }
        if lhs.outputs != rhs.outputs { return false }
        if lhs.actions != rhs.actions { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension CompactSaplingSpend: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".CompactSaplingSpend"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "nf"),
    ]

    public mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch fieldNumber {
            case 1: try decoder.decodeSingularBytesField(value: &nf)
            default: break
            }
        }
    }

    public func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
        if !nf.isEmpty {
            try visitor.visitSingularBytesField(value: nf, fieldNumber: 1)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: CompactSaplingSpend, rhs: CompactSaplingSpend) -> Bool {
        if lhs.nf != rhs.nf { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension CompactSaplingOutput: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".CompactSaplingOutput"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "cmu"),
        2: .same(proto: "ephemeralKey"),
        3: .same(proto: "ciphertext"),
    ]

    public mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch fieldNumber {
            case 1: try decoder.decodeSingularBytesField(value: &cmu)
            case 2: try decoder.decodeSingularBytesField(value: &ephemeralKey)
            case 3: try decoder.decodeSingularBytesField(value: &ciphertext)
            default: break
            }
        }
    }

    public func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
        if !cmu.isEmpty {
            try visitor.visitSingularBytesField(value: cmu, fieldNumber: 1)
        }
        if !ephemeralKey.isEmpty {
            try visitor.visitSingularBytesField(value: ephemeralKey, fieldNumber: 2)
        }
        if !ciphertext.isEmpty {
            try visitor.visitSingularBytesField(value: ciphertext, fieldNumber: 3)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: CompactSaplingOutput, rhs: CompactSaplingOutput) -> Bool {
        if lhs.cmu != rhs.cmu { return false }
        if lhs.ephemeralKey != rhs.ephemeralKey { return false }
        if lhs.ciphertext != rhs.ciphertext { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension CompactOrchardAction: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    public static let protoMessageName: String = _protobuf_package + ".CompactOrchardAction"
    public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "nullifier"),
        2: .same(proto: "cmx"),
        3: .same(proto: "ephemeralKey"),
        4: .same(proto: "ciphertext"),
    ]

    public mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            // The use of inline closures is to circumvent an issue where the compiler
            // allocates stack space for every case branch when no optimizations are
            // enabled. https://github.com/apple/swift-protobuf/issues/1034
            switch fieldNumber {
            case 1: try decoder.decodeSingularBytesField(value: &nullifier)
            case 2: try decoder.decodeSingularBytesField(value: &cmx)
            case 3: try decoder.decodeSingularBytesField(value: &ephemeralKey)
            case 4: try decoder.decodeSingularBytesField(value: &ciphertext)
            default: break
            }
        }
    }

    public func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
        if !nullifier.isEmpty {
            try visitor.visitSingularBytesField(value: nullifier, fieldNumber: 1)
        }
        if !cmx.isEmpty {
            try visitor.visitSingularBytesField(value: cmx, fieldNumber: 2)
        }
        if !ephemeralKey.isEmpty {
            try visitor.visitSingularBytesField(value: ephemeralKey, fieldNumber: 3)
        }
        if !ciphertext.isEmpty {
            try visitor.visitSingularBytesField(value: ciphertext, fieldNumber: 4)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    public static func == (lhs: CompactOrchardAction, rhs: CompactOrchardAction) -> Bool {
        if lhs.nullifier != rhs.nullifier { return false }
        if lhs.cmx != rhs.cmx { return false }
        if lhs.ephemeralKey != rhs.ephemeralKey { return false }
        if lhs.ciphertext != rhs.ciphertext { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
