//
//  SetDetailView.swift
//  fit
//
//  Created by Cedric Kienzler on 10.01.25.
//

import SwiftUI

struct SetDetailView: View {
    @Binding var sets: [ExerciseSet]

    let completeSet: (Binding<ExerciseSet>, ScrollViewProxy, Bool) -> Void

    let buttonWidth: CGFloat = 40
    let buttonSpacing: CGFloat = 4

    @State private var setsWidth: CGFloat = 0
    private let setsMaxWidth: CGFloat

    init(
        sets: Binding<[ExerciseSet]>,
        completeSet: @escaping (Binding<ExerciseSet>, ScrollViewProxy, Bool) ->
            Void
    ) {
        self._sets = sets

        self.setsWidth =
            (buttonWidth * CGFloat(sets.wrappedValue.count))
            + (buttonSpacing * CGFloat(sets.wrappedValue.count - 1))
        self.setsMaxWidth = (buttonWidth * 3) + (buttonSpacing * 2)
        self.completeSet = completeSet
    }

    var body: some View {
        HStack(alignment: .top) {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 4) {
                    ForEach($sets) { $set in
                        Button(action: {
                            completeSet($set, proxy, false)
                        }) {
                            HStack(alignment: .center, spacing: 4) {
                                Image(
                                    systemName: set.isPr
                                        ? "trophy.circle"
                                        : set.isCompleted
                                            ? "checkmark.circle.fill"
                                            : set.isSkipped
                                                ? "x.circle" : "circle"
                                )
                                .foregroundColor(
                                    set.isSkipped
                                        ? Color.red
                                        : set.isPr
                                            ? Color.yellow : Color.accentColor
                                )

                                Text("Set \(set.setNumber):").bold()

                                if set.weight == 0 {
                                    Text("\(set.reps) reps").bold(false)
                                } else {
                                    Text(
                                        "\(set.reps) reps @ \(set.weight) kg"
                                    )
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())  // Remove default button styling
                        .padding(.horizontal, 4)  // Padding only on left and right
                    }
                }
            }
            .font(.subheadline)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Add PR")
                        Image(systemName: "trophy")
                            .frame(width: 32)
                    }
                }
                .foregroundColor(Color.orange)

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Add Note")
                        Image(systemName: "pencil.and.list.clipboard")
                            .frame(width: 32)
                    }
                }

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Add Video")
                        Image(systemName: "video")
                            .frame(width: 32)
                    }
                }
            }
            .font(.headline)
        }
    }
}

#Preview {
    var sets = [
        ExerciseSet(
            id: 1, setNumber: 1, weight: 100, reps: 10, isCompleted: true),
        ExerciseSet(
            id: 2, setNumber: 2, weight: 220, reps: 10, isSkipped: true),
        ExerciseSet(
            id: 3, setNumber: 3, weight: 333, reps: 10, isPr: true),
        ExerciseSet(
            id: 4, setNumber: 4, weight: 333, reps: 10, isPr: true),
    ]

    SetDetailView(
        sets: .constant(sets),
        completeSet: { set, _, _ in
            // Example action: Toggle completion
            if let index = sets.firstIndex(where: { $0.id == set.id }) {
                withAnimation {
                    sets[index].isCompleted.toggle()
                }
            }
        })
}
