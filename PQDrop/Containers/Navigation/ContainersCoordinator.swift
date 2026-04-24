//
//  ContainersCoordinator.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 20.03.2026.
//

import SwiftUI
import SUICoordinator

@MainActor
final class ContainersCoordinator: Coordinator<ContainersRoute>, ContainersCoordinatorProtocol {

    override init() {
        super.init()
        Task { [weak self] in
            await self?.start()
        }
    }

    override func start() async {
        await startFlow(route: .containers(coordinator: self))
    }

    func finish() async {
        await restart()
    }

    func showContainerDetails(with container: Container) async {
        await navigate(toRoute: .containerDetails(coordinator: self, container: container))
    }

    func showImportContainerValidation(fileURL: URL) async {
        await navigate(toRoute: .importContainer(coordinator: self, fileURL: fileURL))
    }

    func showRecipientsSheet(recipients: [Recipient]) async {
        await navigate(toRoute: .recipientsSheet(recipients: recipients))
    }

    func showAccessControl(with container: Container) async {
        await navigate(toRoute: .accessControl(coordinator: self, container: container))
    }
    
    func showContainerContents(with container: Container, workspaceRoot: URL) async {
        await navigate(toRoute: .containersContents(coordinator: self, container: container, workspaceRoot: workspaceRoot))
    }
    
    func showFileViewer(with item: ContainerFileItem) async {
        await navigate(toRoute: .fileViewer(item: item))
    }

    func showSaveContainer(with container: Container) async {
        await navigate(toRoute: .saveContainer(coordinator: self, container: container))
    }

    func showEditContainerName(mode: EditContainerNameViewModel.Mode) async {
        await navigate(toRoute: .editContainerName(coordinator: self, mode: mode))
    }

    func showCreateContainerFiles(name: String) async {
        await navigate(toRoute: .createContainerFiles(coordinator: self, name: name))
    }

    func showCreateContainerSave(
        name: String,
        files: [ContainerFileItem],
        workspaceRoot: URL
    ) async {
        await navigate(
            toRoute: .createContainerSave(
                coordinator: self,
                name: name,
                files: files,
                workspaceRoot: workspaceRoot
            )
        )
    }

    func pop() async {
        await router.pop(animated: true)
    }
}
