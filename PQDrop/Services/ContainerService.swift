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
        
        var allRecipients = recipients
        
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
            fileURL: containerURL
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
}

struct ContainerResult {
    let containerID: Data
    let fileURL: URL
}

enum ContainerServiceError: Error {
    case noKeyPair
}
