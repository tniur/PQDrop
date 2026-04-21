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
        return keyPair.publicKey
    }

    func loadPublicKey() throws -> XWing.PublicKey? {
        try keychainService.loadPrivateKey()?.publicKey
    }

    func loadPrivateKey() throws -> XWing.PrivateKey? {
        try keychainService.loadPrivateKey()
    }

    func deleteKeyPair() {
        keychainService.deletePrivateKey()
    }

    func hasKeyPair() -> Bool {
        keychainService.hasPrivateKey()
    }
}
