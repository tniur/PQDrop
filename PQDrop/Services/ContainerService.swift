//
//  ContainerService.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 20.04.2026.
//

import Foundation
import PQContainerKit

final class ContainerService {
    
    private let archiveService: ArchiveService
    private let keyPairManager: KeyPairManager
    
    init(archiveService: ArchiveService, keyPairManager: KeyPairManager) {
        self.archiveService = archiveService
        self.keyPairManager = keyPairManager
    }
    
    func createContainer(
        name: String,
        files: [URL],
        recipients: [XWing.PublicKey],
        destinationDir: URL
    ) throws -> ContainerResult {
        let containerID = ContainerID.random()
        let archiveURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("aar")
        
        defer {
            try? FileManager.default.removeItem(at: archiveURL)
        }
        
        try archiveService.pack(files: files, to: archiveURL)
        
        guard let ownerKey = try keyPairManager.loadOrMigratePublicKey() else {
            throw ContainerServiceError.noKeyPair
        }

        var allRecipients = deduplicatedRecipientKeys(recipients)

        if !allRecipients.contains(ownerKey) {
            allRecipients.insert(ownerKey, at: 0)
        }
        
        let fileName = "\(name).pqck"
        let containerURL = destinationDir.appendingPathComponent(fileName)
        
        try ContainerV1.encryptFile(
            sourceURL: archiveURL,
            destinationURL: containerURL,
            recipients: allRecipients,
            owner: ownerKey,
            containerID: containerID
        )
        
        return ContainerResult(
            containerID: containerID.rawValue,
            fileURL: containerURL,
            recipientPublicKeysRaw: normalizedNonOwnerRecipientPublicKeysRaw(
                from: allRecipients,
                ownerKey: ownerKey
            )
        )
    }
    
    func inspectContainer(at url: URL) throws -> ContainerInfo {
        try ContainerV1.inspectFile(url)
    }
    
    func decryptContainer(at url: URL, to destinationDir: URL) throws -> [URL] {
        guard let privateKey = try keyPairManager.loadPrivateKey() else {
            throw ContainerServiceError.noKeyPair
        }

        return try decryptContainer(at: url, to: destinationDir, privateKey: privateKey)
    }

    func decryptContainer(
        at url: URL,
        to destinationDir: URL,
        privateKey: XWing.PrivateKey
    ) throws -> [URL] {
        let decryptedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("aar")
        
        defer {
            try? FileManager.default.removeItem(at: decryptedURL)
        }
        
        try ContainerV1.decryptFile(
            sourceURL: url,
            destinationURL: decryptedURL,
            myPrivateKey: privateKey,
            myPublicKey: privateKey.publicKey
        )
        
        try archiveService.unpack(archiveURL: decryptedURL, to: destinationDir)
        
        return try FileManager.default.contentsOfDirectory(
            at: destinationDir,
            includingPropertiesForKeys: [.fileSizeKey, .nameKey]
        )
    }
    
    func rekeyContainer(
        at sourceURL: URL,
        to destinationURL: URL,
        remainingRecipients: [XWing.PublicKey]
    ) throws {
        guard let privateKey = try keyPairManager.loadPrivateKey() else {
            throw ContainerServiceError.noKeyPair
        }

        try rekeyContainer(
            at: sourceURL,
            to: destinationURL,
            remainingRecipients: remainingRecipients,
            privateKey: privateKey
        )
    }

    func rekeyContainer(
        at sourceURL: URL,
        to destinationURL: URL,
        remainingRecipients: [XWing.PublicKey],
        privateKey: XWing.PrivateKey
    ) throws {
        try ContainerV1.rekeyFile(
            sourceURL: sourceURL,
            destinationURL: destinationURL,
            remainingRecipients: remainingRecipients,
            myPrivateKey: privateKey,
            myPublicKey: privateKey.publicKey
        )
    }
    
    func reencryptContainer(
        name: String,
        files: [URL],
        originalContainerURL: URL,
        destinationURL: URL,
        recipients: [XWing.PublicKey]
    ) throws {
        let info = try ContainerV1.inspectFile(originalContainerURL)
        
        guard let ownerKey = try keyPairManager.loadOrMigratePublicKey() else {
            throw ContainerServiceError.noKeyPair
        }
        
        let archiveURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("aar")
        
        defer {
            try? FileManager.default.removeItem(at: archiveURL)
        }
        
        try archiveService.pack(files: files, to: archiveURL)

        try ContainerV1.encryptFile(
            sourceURL: archiveURL,
            destinationURL: destinationURL,
            recipients: recipients,
            owner: ownerKey,
            containerID: info.header.containerID
        )
    }

    func mergedCurrentNonOwnerRecipientPublicKeys(
        at url: URL,
        storedRecipientPublicKeysRaw: [Data],
        candidateRecipientPublicKeysRaw: [Data]
    ) throws -> [Data] {
        let info = try inspectContainer(at: url)
        var currentRecipientFingerprints = Set(info.recipientKeyIds)

        if let ownerFingerprint = try keyPairManager.loadPublicKey()?.fingerprint {
            currentRecipientFingerprints.remove(ownerFingerprint)
        }

        guard !currentRecipientFingerprints.isEmpty else {
            return []
        }

        let candidateRawKeys = deduplicatedRawRecipientKeys(
            storedRecipientPublicKeysRaw + candidateRecipientPublicKeysRaw
        )

        return candidateRawKeys.filter { rawKey in
            guard let publicKey = try? XWing.PublicKey(rawRepresentation: rawKey) else {
                return false
            }

            return currentRecipientFingerprints.contains(publicKey.fingerprint)
        }
    }

    func resolveCurrentNonOwnerRecipients(
        at url: URL,
        storedRecipientPublicKeysRaw: [Data],
        contacts: [Contact]
    ) throws -> ResolvedContainerRecipients {
        guard let ownerKey = try keyPairManager.loadOrMigratePublicKey() else {
            throw ContainerServiceError.noKeyPair
        }

        let info = try inspectContainer(at: url)
        let currentRecipientFingerprints = Set(info.recipientKeyIds)
            .subtracting([ownerKey.fingerprint])

        guard !currentRecipientFingerprints.isEmpty else {
            return ResolvedContainerRecipients(
                publicKeys: [],
                rawPublicKeys: [],
                hiddenPublicKeys: []
            )
        }

        let contactFingerprints = Set(contacts.map { Fingerprint.fromPublicKeyRaw($0.publicKeyRaw) })
        let mergedRawKeys = try mergedCurrentNonOwnerRecipientPublicKeys(
            at: url,
            storedRecipientPublicKeysRaw: storedRecipientPublicKeysRaw,
            candidateRecipientPublicKeysRaw: contacts.map(\.publicKeyRaw)
        )

        var unresolvedFingerprints = currentRecipientFingerprints
        var resolvedPublicKeys: [XWing.PublicKey] = []
        var resolvedRawPublicKeys: [Data] = []
        var hiddenPublicKeys: [XWing.PublicKey] = []

        for rawKey in mergedRawKeys {
            guard let publicKey = try? XWing.PublicKey(rawRepresentation: rawKey) else {
                continue
            }

            let fingerprint = publicKey.fingerprint

            guard fingerprint != ownerKey.fingerprint,
                  unresolvedFingerprints.contains(fingerprint) else {
                continue
            }

            unresolvedFingerprints.remove(fingerprint)
            resolvedPublicKeys.append(publicKey)
            resolvedRawPublicKeys.append(rawKey)

            if !contactFingerprints.contains(fingerprint) {
                hiddenPublicKeys.append(publicKey)
            }
        }

        guard unresolvedFingerprints.isEmpty else {
            throw ContainerServiceError.recipientKeysUnavailable
        }

        return ResolvedContainerRecipients(
            publicKeys: resolvedPublicKeys,
            rawPublicKeys: resolvedRawPublicKeys,
            hiddenPublicKeys: hiddenPublicKeys
        )
    }

    private func normalizedNonOwnerRecipientPublicKeysRaw(
        from recipients: [XWing.PublicKey],
        ownerKey: XWing.PublicKey
    ) -> [Data] {
        deduplicatedRecipientKeys(recipients)
            .filter { $0 != ownerKey }
            .map(\.rawRepresentation)
    }

    private func deduplicatedRecipientKeys(_ recipients: [XWing.PublicKey]) -> [XWing.PublicKey] {
        var seenFingerprints: Set<Fingerprint> = []
        var uniqueRecipients: [XWing.PublicKey] = []

        for recipient in recipients where seenFingerprints.insert(recipient.fingerprint).inserted {
            uniqueRecipients.append(recipient)
        }

        return uniqueRecipients
    }

    private func deduplicatedRawRecipientKeys(_ rawKeys: [Data]) -> [Data] {
        var seenFingerprints: Set<Fingerprint> = []
        var uniqueRawKeys: [Data] = []

        for rawKey in rawKeys {
            guard let publicKey = try? XWing.PublicKey(rawRepresentation: rawKey) else {
                continue
            }

            guard seenFingerprints.insert(publicKey.fingerprint).inserted else {
                continue
            }

            uniqueRawKeys.append(rawKey)
        }

        return uniqueRawKeys
    }
}

struct ContainerResult {
    let containerID: Data
    let fileURL: URL
    let recipientPublicKeysRaw: [Data]
}

enum ContainerServiceError: Error {
    case noKeyPair
    case recipientKeysUnavailable
}

struct ResolvedContainerRecipients {
    let publicKeys: [XWing.PublicKey]
    let rawPublicKeys: [Data]
    let hiddenPublicKeys: [XWing.PublicKey]
}
