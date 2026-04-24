//
//  ContainerPlaintextWorkspace.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 23.04.2026.
//

import Foundation

struct ContainerPlaintextWorkspace {
    let rootURL: URL

    var decryptedDirectory: URL {
        rootURL.appendingPathComponent("decrypted", isDirectory: true)
    }

    var draftsDirectory: URL {
        rootURL.appendingPathComponent("drafts", isDirectory: true)
    }

    static func create() throws -> ContainerPlaintextWorkspace {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("container_workspace_\(UUID().uuidString)", isDirectory: true)

        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: rootURL.appendingPathComponent("decrypted", isDirectory: true),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: rootURL.appendingPathComponent("drafts", isDirectory: true),
            withIntermediateDirectories: true
        )

        return ContainerPlaintextWorkspace(rootURL: rootURL)
    }

    func makeDraftFileURL(pathExtension: String) -> URL {
        draftsDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(pathExtension)
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: rootURL)
    }
}
