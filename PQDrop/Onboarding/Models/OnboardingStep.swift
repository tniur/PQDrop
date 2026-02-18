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
            title: "Локальное крипто-хранилище для файлов",
            subtitle: "Шифрует файлы прямо на устройстве. Делитесь контейнерами без серверов и облаков."
        ),
        .init(
            id: 1,
            image: PQImage.containerOpen.swiftUIImage,
            title: "Файл превращается в защищённый контейнер",
            subtitle: "Приложение шифрует содержимое и сохраняет его локально. Даже если контейнер перехватят — без ключа его не открыть.",
            mark: "Шифрование: AES-GCM + постквантовая выдача прав доступа"
        ),
        .init(
            id: 2,
            image: PQImage.containerClose.swiftUIImage,
            title: "Оффлайн-обмен с контролем доступа",
            subtitle: "Контейнер отправляется любым способом (AirDrop/экспорт). Право открыть — передаётся отдельно через QR-код.",
            mark: "Ключ можно передать по другому каналу – так снижается риск MITM."
        ),
        .init(
            id: 3,
            image: PQImage.checkId.swiftUIImage,
            title: "Проверяйте подлинность ключей",
            subtitle: "Публичный ключ можно подменить при обмене. Сверьте fingerprint по независимому каналу и отметьте контакт как Verified."
        ),
        .init(
            id: 4,
            image: PQImage.fileAlert.swiftUIImage,
            title: "Важно: это не DRM",
            subtitle: "Если получатель расшифровал и сохранил файл, “забрать назад” его нельзя без серверов или DRM-механизмов.",
            mark: "Но перехват контейнера ≠ утечка содержимого."
        )
    ]
}
