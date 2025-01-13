//
//  SetView.swift
//  fit
//
//  Created by Cedric Kienzler on 10.01.25.
//


import SwiftUI

struct SetView: View {
    @Binding var sets: [ExerciseSet]
    @Binding var detailView: Bool
    @Binding var exerciseComplete: Bool

    let buttonWidth: CGFloat = 40
    let buttonSpacing: CGFloat = 4

    @State private var setsWidth: CGFloat = 0
    private let setsMaxWidth: CGFloat

    init(
        sets: Binding<[ExerciseSet]>, detailView: Binding<Bool>,
        exerciseComplete: Binding<Bool>
    ) {
        self._sets = sets
        self._detailView = detailView
        self._exerciseComplete = exerciseComplete

        self.setsWidth =
            (buttonWidth * CGFloat(sets.wrappedValue.count))
            + (buttonSpacing * CGFloat(sets.wrappedValue.count - 1))
        self.setsMaxWidth = (buttonWidth * 3) + (buttonSpacing * 2)
    }

    var body: some View {

        if detailView {
            SetDetailView(sets: $sets, completeSet: completeSet)
        } else {
            SetButtonsView(sets: $sets, completeSet: completeSet)
        }
    }

    private func completeSet(set: Binding<ExerciseSet>, proxy: ScrollViewProxy?)
    {
        // Check if there are any uncompleted sets
        if let firstUncompletedIndex = sets.firstIndex(where: {
            !$0.isCompleted
        }) {
            // If the clicked set is uncompleted, complete the first uncompleted set
            if !set.wrappedValue.isCompleted {

                if detailView {
                    sets[firstUncompletedIndex].isCompleted.toggle()
                } else {
                    withAnimation {
                        sets[firstUncompletedIndex].isCompleted.toggle()
                    }
                }

                // Scroll to the next uncompleted set, if any
                if let nextUncompletedIndex = sets.indices.first(where: {
                    $0 > firstUncompletedIndex && !sets[$0].isCompleted
                }) {
                    guard let proxy = proxy else {
                        return
                    }

                    withAnimation {
                        proxy.scrollTo(
                            sets[nextUncompletedIndex].id, anchor: .center)
                    }
                }

                // Check if all sets are completed
                if sets.allSatisfy({ $0.isCompleted }) {
                    withAnimation(.bouncy) {
                        exerciseComplete = true
                    }
                }
                return
            }
        }

        // Check if there are any completed sets
        if let lastCompletedIndex = sets.lastIndex(where: { $0.isCompleted }) {
            // If the clicked set is completed, un-complete the last completed set
            if set.wrappedValue.isCompleted {

                if detailView {
                    sets[lastCompletedIndex].isCompleted.toggle()
                } else {
                    withAnimation {
                        sets[lastCompletedIndex].isCompleted.toggle()
                    }
                }

                guard let proxy = proxy else {
                    return
                }

                // Scroll back to the last completed set
                withAnimation {
                    proxy.scrollTo(
                        sets[lastCompletedIndex].id, anchor: .center)

                    // Since a set was uncompleted, set exerciseCompleted to false
                    exerciseComplete = false
                }
            }
        }
    }
}

struct SetPreviewWrapper: View {
    @State var detailView: Bool = false
    @State var exerciseComplete: Bool = false
    
    @State var sets = [
        ExerciseSet(id: 1, setNumber: 1, weight: 100, reps: 10, isCompleted: true),
        ExerciseSet(id: 2, setNumber: 2, weight: 220, reps: 10, isCompleted: false),
        ExerciseSet(id: 3, setNumber: 3, weight: 333, reps: 10, isCompleted: false)
    ]

    var body: some View {
        SetView(sets: $sets, detailView: $detailView, exerciseComplete: $exerciseComplete)
    }
}

#Preview {
    SetButtonsPreviewWrapper()
}
