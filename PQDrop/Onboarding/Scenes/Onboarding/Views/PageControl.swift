//
//  PageControl.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 17.02.2026.
//

import SwiftUI
import UIKit
import PQUIComponents

struct PageControl: UIViewRepresentable {
    
    @Binding var currentPage: Int

    private let numberOfPages: Int
    private let currentColor: UIColor = PQColor.base10.color
    private let otherColor: UIColor = PQColor.base4.color

    init(currentPage: Binding<Int>, numberOfPages: Int) {
        self._currentPage = currentPage
        self.numberOfPages = numberOfPages
    }
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.backgroundStyle = .minimal
        control.isUserInteractionEnabled = false
        control.backgroundColor = .clear

        control.numberOfPages = numberOfPages
        control.currentPageIndicatorTintColor = currentColor
        control.pageIndicatorTintColor = otherColor
        return control
    }

    func updateUIView(_ control: UIPageControl, context: Context) {
        control.numberOfPages = numberOfPages
        control.currentPage = currentPage
        control.currentPageIndicatorTintColor = currentColor
        control.pageIndicatorTintColor = otherColor
    }
}
