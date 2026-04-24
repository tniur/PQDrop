//
//  ContainersCoordinatorProtocol.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import Foundation

protocol ContainersCoordinatorProtocol: AnyObject {
    func finish() async
    func showContainerDetails(with container: Container) async
    func showImportContainerValidation(fileURL: URL) async
    func showRecipientsSheet(recipients: [Recipient]) async
    func showAccessControl(with container: Container) async
    func showContainerContents(with container: Container, workspaceRoot: URL) async
    func showFileViewer(with item: ContainerFileItem) async
    func showSaveContainer(with container: Container) async
    func showEditContainerName(mode: EditContainerNameViewModel.Mode) async
    func showCreateContainerFiles(name: String) async
    func showCreateContainerSave(
        name: String,
        files: [ContainerFileItem],
        workspaceRoot: URL
    ) async
    func pop() async
}
