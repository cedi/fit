//
//  SetView.swift
//  fit
//
//  Created by Cedric Kienzler on 10.01.25.
//

import SharedModels
import SwiftUI

struct SetView: View {
    @Binding var sets: [ExerciseSet]
    @Binding var detailView: Bool
    let completeSet: (Binding<ExerciseSet>, Bool) -> Void

    let buttonWidth: CGFloat = 40
    let buttonSpacing: CGFloat = 4

    @State private var setsWidth: CGFloat = 0
    private let setsMaxWidth: CGFloat

    init(
        sets: Binding<[ExerciseSet]>,
        detailView: Binding<Bool>,
        completeSet: @escaping (Binding<ExerciseSet>, Bool) -> Void
    ) {
        self._sets = sets
        self._detailView = detailView
        self.completeSet = completeSet

        self.setsWidth =
            (buttonWidth * CGFloat(sets.wrappedValue.count))
            + (buttonSpacing * CGFloat(sets.wrappedValue.count - 1))
        self.setsMaxWidth = (buttonWidth * 3) + (buttonSpacing * 2)
    }

    var body: some View {
        ZStack {
            if detailView {
                SetDetailView(sets: $sets, completeSet: completeSet)
            } else {
                SetButtonsView(sets: $sets, completeSet: completeSet)
            }
        }
    }
}

#Preview {
    let sets = [
        ExerciseSet(
            id: 1, setNumber: 1, weight: 100, reps: 10, isCompleted: true),
        ExerciseSet(
            id: 2, setNumber: 2, weight: 220, reps: 10, isCompleted: false),
        ExerciseSet(
            id: 3, setNumber: 3, weight: 333, reps: 10, isCompleted: false),
        ExerciseSet(
            id: 4, setNumber: 4, weight: 333, reps: 10, isCompleted: false),
    ]

    SetView(
        sets: .constant(sets),
        detailView: .constant(false),
        completeSet: { _, _ in }
    )

    SetView(
        sets: .constant(sets),
        detailView: .constant(true),
        completeSet: { _, _ in }
    )
}
