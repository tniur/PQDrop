//
//  KeychainService.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 19.04.2026.
//

import Foundation
import LocalAuthentication
import PQContainerKit
import Security

final class KeychainService {

    private let privateKeyService = "pq.user.privateKey"

    func storePrivateKey(_ privateKey: XWing.PrivateKey) throws {
        let data = privateKey.rawRepresentation

        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: privateKeyService
        ]

        SecItemDelete(deleteQuery as CFDictionary)

        var error: Unmanaged<CFError>?

        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .biometryCurrentSet,
            &error
        ) else {
            throw KeychainError.saveFailed(errSecParam)
        }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: privateKeyService,
            kSecAttrAccessControl as String: accessControl,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func loadPrivateKey() throws -> XWing.PrivateKey? {
        let context = LAContext()
        context.localizedReason = "Доступ к ключу шифрования"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: privateKeyService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]

        var result: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.loadFailed(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return try XWing.PrivateKey(rawRepresentation: data)
    }

    func deletePrivateKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: privateKeyService
        ]

        SecItemDelete(query as CFDictionary)
    }

    func hasPrivateKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: privateKeyService,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUISkip
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case invalidData
}
