//
//  QuickLookPreviewRepresentable.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 09.04.2026.
//

import SwiftUI
import QuickLook

struct QuickLookPreviewRepresentable: UIViewControllerRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIViewController(context: Context) -> ContainedQLPreviewController {
        let controller = ContainedQLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ContainedQLPreviewController, context: Context) {}

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) {
            self.url = url
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

// MARK: - Contained QLPreviewController

/// `QLPreviewController` has an internal swipe-to-dismiss gesture that calls
/// `self.dismiss(animated:)`. Inside a SwiftUI `NavigationStack` that lives inside
/// a `.fullScreenCover` (our `MainTabCoordinator` is presented this way in
/// `AppCoordinator.showMainTabs()`), that call walks up the parent chain, finds
/// the fullScreenCover's hosting controller as the nearest presented VC, and
/// dismisses *the entire tab flow*, dumping the user back to the splash screen.
///
/// We subclass `QLPreviewController` and intercept `dismiss(animated:)` at the
/// one place it is actually called — on QL itself. If QL is currently presenting
/// something (its own share sheet, the "open in…" menu, etc.), we forward the
/// dismissal so those modals can close normally. Otherwise, we swallow the call:
/// the user can still leave the screen via swipe-right from the edge or the
/// navigation bar back button, exactly like every other pushed screen.
final class ContainedQLPreviewController: QLPreviewController {

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }

        completion?()
    }
}
