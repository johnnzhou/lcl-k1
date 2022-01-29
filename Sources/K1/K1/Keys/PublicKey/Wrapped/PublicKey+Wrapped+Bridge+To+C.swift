//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-01-27.
//

import Foundation

import secp256k1

extension Bridge {
    
    static func publicKeyParse(
        raw: [UInt8]
    ) throws -> Data {
        
        var publicKeyBytes = raw
        var publicKeyBridgedToC = secp256k1_pubkey()
        
        try Self.call(
            ifFailThrow: .failedToSerializePublicKeyIntoBytes
        ) { context in
            /* "Serialize a pubkey object into a serialized byte sequence." */
            secp256k1_ec_pubkey_parse(
                context,
                &publicKeyBridgedToC,
                &publicKeyBytes,
                raw.count
            )
        }
        
        return Data(publicKeyBytes)
    }
    
    
    static func publicKeyCreate(privateKeyBytes: [UInt8]) throws -> Data {
        
        guard
            privateKeyBytes.count == K1.PrivateKey.Wrapped.byteCount
        else {
            throw K1.Error.incorrectByteCountOfPrivateKey
        }
        
        let publicKeyFormat = K1.Format.uncompressed
        var publicKeyByteCount = publicKeyFormat.length
        var publicKeyBridgedToC = secp256k1_pubkey()
        
        var publicKeyBytes = [UInt8](
            repeating: 0,
            count: publicKeyFormat.length
        )
        
        try Bridge.toC { bridge in
            
            try bridge.call(
                ifFailThrow: .failedToUpdateContextRandomization
            ) {
                secp256k1_context_randomize($0, privateKeyBytes)
            }
            
            try bridge.call(
                ifFailThrow: .failedToComputePublicKeyFromPrivateKey
            ) {
                /* "Compute the public key for a secret key." */
                secp256k1_ec_pubkey_create($0, &publicKeyBridgedToC, privateKeyBytes)
            }
            
            try bridge.call(
                ifFailThrow: .failedToSerializePublicKeyIntoBytes
            ) {
                /* "Serialize a pubkey object into a serialized byte sequence." */
                secp256k1_ec_pubkey_serialize(
                    $0,
                    &publicKeyBytes,
                    &publicKeyByteCount,
                    &publicKeyBridgedToC,
                    publicKeyFormat.rawValue
                )
            }
        }
        
        assert(publicKeyByteCount == publicKeyFormat.length)
        
        return Data(publicKeyBytes)
    }
}


internal extension K1.PublicKey.Wrapped {
    
    static func `import`(from raw: [UInt8]) throws -> Self {
        let publicKeyBytes = try Bridge.publicKeyParse(raw: raw)
        return try Self(publicKeyRaw: publicKeyBytes.bytes)
    }
    
    static func derive(
        privateKeyBytes: [UInt8]
    ) throws -> Self {
        let publicKeyRaw = try Bridge.publicKeyCreate(privateKeyBytes: privateKeyBytes)
        return try Self(publicKeyRaw: publicKeyRaw.bytes)
    }
}