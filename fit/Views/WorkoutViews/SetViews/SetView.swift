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
    @Binding var workoutStarted: Bool

    let buttonWidth: CGFloat = 40
    let buttonSpacing: CGFloat = 4

    @State private var setsWidth: CGFloat = 0
    private let setsMaxWidth: CGFloat

    init(
        sets: Binding<[ExerciseSet]>, detailView: Binding<Bool>,
        workoutStarted: Binding<Bool>
    ) {
        self._sets = sets
        self._detailView = detailView
        self._workoutStarted = workoutStarted

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

    private func completeSet(
        set: Binding<ExerciseSet>, proxy: ScrollViewProxy?, skipSet: Bool
    ) {
        // Check if there are any incomplete sets (not completed and not skipped)
        if let firstIncompleteIndex = sets.firstIndex(where: {
            !$0.isCompleted && !$0.isSkipped
        }) {
            // If the clicked set is incomplete, mark the first incomplete set as completed or skipped
            if !set.wrappedValue.isCompleted && !set.wrappedValue.isSkipped {
                if detailView {
                    if skipSet {
                        sets[firstIncompleteIndex].isSkipped = true
                    } else {
                        sets[firstIncompleteIndex].isCompleted = true
                    }
                } else {
                    withAnimation {
                        if skipSet {
                            sets[firstIncompleteIndex].isSkipped = true
                        } else {
                            sets[firstIncompleteIndex].isCompleted = true
                        }
                    }
                }

                // Scroll to the next incomplete set, if any
                if let nextIncompleteIndex = sets.indices.first(where: {
                    $0 > firstIncompleteIndex && !sets[$0].isCompleted
                        && !sets[$0].isSkipped
                }) {
                    guard let proxy = proxy else {
                        return
                    }

                    withAnimation {
                        proxy.scrollTo(
                            sets[nextIncompleteIndex].id, anchor: .center)
                    }
                }

                if !workoutStarted {
                    withAnimation {
                        workoutStarted = true
                    }
                }

                return
            }
        }

        // Check if there are any completed or skipped sets
        if let lastHandledIndex = sets.lastIndex(where: {
            $0.isCompleted || $0.isSkipped
        }) {
            // If the clicked set is completed or skipped, undo the last handled set
            if set.wrappedValue.isCompleted || set.wrappedValue.isSkipped {
                if detailView {
                    if sets[lastHandledIndex].isCompleted {
                        sets[lastHandledIndex].isCompleted = false
                    } else if sets[lastHandledIndex].isSkipped {
                        sets[lastHandledIndex].isSkipped = false
                    }
                } else {
                    withAnimation {
                        if sets[lastHandledIndex].isCompleted {
                            sets[lastHandledIndex].isCompleted = false
                        } else if sets[lastHandledIndex].isSkipped {
                            sets[lastHandledIndex].isSkipped = false
                        }
                    }
                }

                guard let proxy = proxy else {
                    return
                }

                // Scroll back to the last handled set
                withAnimation {
                    proxy.scrollTo(
                        sets[lastHandledIndex].id, anchor: .center)
                }
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
        workoutStarted: .constant(false)
    )

    SetView(
        sets: .constant(sets),
        detailView: .constant(true),
        workoutStarted: .constant(true)
    )
}
