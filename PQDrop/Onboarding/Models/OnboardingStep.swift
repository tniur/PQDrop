//
//  OnboardingStep.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 17.02.2026.
//

import SwiftUI
import PQUIComponents

struct OnboardingStep: Identifiable, Equatable {
    let id: Int
    let image: Image
    let title: String
    let subtitle: String
    let mark: String?
    
    init(
        id: Int,
        image: Image,
        title: String,
        subtitle: String,
        mark: String? = nil
    ) {
        self.id = id
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.mark = mark
    }
}

extension OnboardingStep {
    static let mock: [OnboardingStep] = [
        .init(
            id: 0,
            image: PQImage.lock.swiftUIImage,
            title: String(localized: "onboarding.step.local.storage.title"),
            subtitle: String(localized: "onboarding.step.local.storage.subtitle")
        ),
        .init(
            id: 1,
            image: PQImage.containerOpen.swiftUIImage,
            title: String(localized: "onboarding.step.secure.container.title"),
            subtitle: String(localized: "onboarding.step.secure.container.subtitle"),
            mark: String(localized: "onboarding.step.secure.container.mark")
        ),
        .init(
            id: 2,
            image: PQImage.containerClose.swiftUIImage,
            title: String(localized: "onboarding.step.offline.access.title"),
            subtitle: String(localized: "onboarding.step.offline.access.subtitle"),
            mark: String(localized: "onboarding.step.offline.access.mark")
        ),
        .init(
            id: 3,
            image: PQImage.checkId.swiftUIImage,
            title: String(localized: "onboarding.step.verify.keys.title"),
            subtitle: String(localized: "onboarding.step.verify.keys.subtitle")
        ),
        .init(
            id: 4,
            image: PQImage.fileAlert.swiftUIImage,
            title: String(localized: "onboarding.step.not.drm.title"),
            subtitle: String(localized: "onboarding.step.not.drm.subtitle"),
            mark: String(localized: "onboarding.step.not.drm.mark")
        )
    ]
}
