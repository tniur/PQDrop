//
//  HistoryView.swift
//  PQDrop
//
//  Created by Анастасия Журавлева on 15.04.2026.
//

import SwiftUI
import PQUIComponents

struct HistoryView: View {

    // MARK: - Properties

    @ObservedObject private var viewModel: HistoryViewModel

    @State private var searchText: String = ""
    // MARK: - Body

    var body: some View {
        BackgroundView(isImage: true) {
            contentView
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("История")
                    .font(PQFont.B30)
                    .foregroundStyle(PQColor.base0.swiftUIColor)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                filterButton
            }
        }
        .alert("Изменить срок хранения?", isPresented: $viewModel.showRetentionAlert) {
            Button("Изменить") {
                viewModel.confirmRetentionChange()
            }

            Button("Отмена", role: .cancel) {
                viewModel.cancelRetentionChange()
            }
        } message: {
            Text(viewModel.retentionAlertMessage)
        }
    }

    // MARK: - Subviews

    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerView

                if viewModel.visibleSections.isEmpty {
                    emptyView
                } else {
                    listView
                }
            }
            .padding()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.retentionSubtitle)
                .font(PQFont.R14)
                .foregroundStyle(PQColor.blue1.swiftUIColor)

            retentionPicker
        }
    }

    private var retentionPicker: some View {
        Picker(
            "",
            selection: Binding(
                get: { viewModel.selectedRetentionPeriod },
                set: { viewModel.requestRetentionChange(to: $0) }
            )
        ) {
            ForEach(HistoryRetentionPeriod.allCases) { period in
                Text(period.title).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var filterButton: some View {
        Button(action: viewModel.showFilters) {
            PQImage.sliders.swiftUIImage
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(PQColor.base7.swiftUIColor)
                .frame(width: 32, height: 32)
        }
    }

    private var listView: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.visibleSections) { section in
                VStack(alignment: .leading, spacing: 16) {
                    Text(section.dateTitle)
                        .font(PQFont.B16)
                        .foregroundStyle(PQColor.base0.swiftUIColor)

                    VStack(spacing: 16) {
                        ForEach(section.events) { event in
                            HistoryEventView(event: event)
                                .onTapGesture {
                                    viewModel.showDetails(of: event)
                                }
                        }
                    }
                }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Text("История пока пуста")
                .font(PQFont.B16)
                .foregroundStyle(PQColor.base0.swiftUIColor)

            Text("Здесь появятся действия с контейнерами и доступом.")
                .font(PQFont.R12)
                .foregroundStyle(PQColor.blue2.swiftUIColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame([.vertical], alignment: .center)
    }

    // MARK: - Initializer

    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
    }
}
