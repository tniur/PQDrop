//
//  ArchiveService.swift
//  PQDrop
//
//  Created by Pavel Bobkov on 20.04.2026.
//

import AppleArchive
import Foundation
import System

enum ArchiveError: Error {
    case packFailed
    case unpackFailed
}

final class ArchiveService {
    
    func pack(files: [URL], to archiveURL: URL) throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        for file in files {
            let destination = tempDir.appendingPathComponent(file.lastPathComponent)
            try FileManager.default.copyItem(at: file, to: destination)
        }
        
        let sourcePath = FilePath(tempDir.path)
        let archivePath = FilePath(archiveURL.path)
        
        guard let writeStream = ArchiveByteStream.fileStream(
            path: archivePath,
            mode: .writeOnly,
            options: [.create, .truncate],
            permissions: [.ownerReadWrite]
        ) else {
            throw ArchiveError.packFailed
        }
        
        defer {
            try? writeStream.close()
        }
        
        guard let compressStream = ArchiveByteStream.compressionStream(
            using: .lzfse,
            writingTo: writeStream
        ) else {
            throw ArchiveError.packFailed
        }
        
        defer {
            try? compressStream.close()
        }
        
        guard let encodeStream = ArchiveStream.encodeStream(writingTo: compressStream) else {
            throw ArchiveError.packFailed
        }
        
        defer {
            try? encodeStream.close()
        }
        
        guard let keySet = ArchiveHeader.FieldKeySet("TYP,PAT,DAT,SIZ") else {
            throw ArchiveError.packFailed
        }
        
        try encodeStream.writeDirectoryContents(
            archiveFrom: sourcePath,
            keySet: keySet
        )
    }
    
    func unpack(archiveURL: URL, to destinationDir: URL) throws {
        try FileManager.default.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        
        let archivePath = FilePath(archiveURL.path)
        let destinationPath = FilePath(destinationDir.path)
        
        guard let readStream = ArchiveByteStream.fileStream(
            path: archivePath,
            mode: .readOnly,
            options: [],
            permissions: []
        ) else {
            throw ArchiveError.unpackFailed
        }
        
        defer {
            try? readStream.close()
        }
        
        guard let decompressStream = ArchiveByteStream.decompressionStream(
            readingFrom: readStream
        ) else {
            throw ArchiveError.unpackFailed
        }
        
        defer {
            try? decompressStream.close()
        }
        
        guard let decodeStream = ArchiveStream.decodeStream(readingFrom: decompressStream) else {
            throw ArchiveError.unpackFailed
        }
        
        defer {
            try? decodeStream.close()
        }
        
        guard let extractStream = ArchiveStream.extractStream(
            extractingTo: destinationPath,
            flags: [.ignoreOperationNotPermitted]
        ) else {
            throw ArchiveError.unpackFailed
        }
        
        defer {
            try? extractStream.close()
        }
        
        _ = try ArchiveStream.process(readingFrom: decodeStream, writingTo: extractStream)
    }
}
