//
//  KeyPairManager.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import PQContainerKit

final class KeyPairManager {

    private let keychainService: KeychainService

    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }

    func generateAndStore() throws -> XWing.PublicKey {
        let keyPair = try XWing.generateKeyPair()
        try keychainService.storePrivateKey(keyPair.privateKey)
        try keychainService.storePublicKey(keyPair.publicKey)
        return keyPair.publicKey
    }

    func loadPublicKey() throws -> XWing.PublicKey? {
        try keychainService.loadPublicKey()
    }

    func loadOrMigratePublicKey() throws -> XWing.PublicKey? {
        if let publicKey = try keychainService.loadPublicKey() {
            return publicKey
        }

        guard let privateKey = try keychainService.loadPrivateKey() else {
            return nil
        }

        let publicKey = privateKey.publicKey
        try keychainService.storePublicKey(publicKey)
        return publicKey
    }

    func loadPublicKeyRequiringAuthentication(reason: String) throws -> XWing.PublicKey? {
        guard let privateKey = try keychainService.loadPrivateKey(reason: reason) else {
            return nil
        }

        let publicKey = privateKey.publicKey
        try? keychainService.storePublicKey(publicKey)
        return publicKey
    }

    func loadPrivateKey() throws -> XWing.PrivateKey? {
        let privateKey = try keychainService.loadPrivateKey()

        if let privateKey {
            try? keychainService.storePublicKey(privateKey.publicKey)
        }

        return privateKey
    }

    func deleteKeyPair() {
        keychainService.deletePrivateKey()
        keychainService.deletePublicKey()
    }

    func hasKeyPair() -> Bool {
        keychainService.hasPrivateKey()
    }
}
