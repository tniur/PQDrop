//
//  OnboardingPage.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 18.02.2026.
//

import SwiftUI
import PQUIComponents

struct OnboardingPage: View {
    private let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: .zero) {
            step.image
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .anchorPreference(key: IconAnchorKey.self, value: .bounds) {
                    [step.id: $0]
                }
                .padding(.bottom, 56)
                        
            Text(step.title)
                .font(PQFont.M24)
                .foregroundStyle(PQColor.base0.swiftUIColor)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            Text(step.subtitle)
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

            if let markText = step.mark {
                Text(markText)
                    .font(PQFont.B14)
                    .foregroundStyle(PQColor.blue2.swiftUIColor)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    init(step: OnboardingStep) {
        self.step = step
    }
}
