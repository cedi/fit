//
//  SetButtonContentView.swift
//  fit
//
//  Created by Cedric Kienzler on 10.01.25.
//

import SwiftUI

struct SetButtonContentView: View {
    @Binding var set: ExerciseSet
    let buttonWidth: CGFloat

    var body: some View {
        ZStack {
            Spacer().frame(width: buttonWidth, height: buttonWidth)
            VStack(spacing: 0) {
                if set.weight == 0 {
                    Text("Reps")
                    Text("x\(set.reps)")
                } else {
                    Text("\(set.reps)x")
                    Text("\(set.weight)kg")
                }
            }.hidden()

            // Show checkmark if completed, otherwise show text
            if set.isCompleted || set.isSkipped {
                Image(systemName: set.isSkipped ? "x.circle" : set.isPr ? "trophy.circle" : "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(
                        set.isSkipped ? Color.red : set.isPr ? Color.yellow : Color.accentColor
                    )
            } else {
                VStack(spacing: 0) {
                    if set.weight == 0 {
                        Text("Reps")
                        Text("x\(set.reps)")
                    } else {
                        Text("\(set.reps)x")
                        Text("\(set.weight)kg")
                    }
                }
            }
        }
        .padding(4)
        .font(.footnote)
    }
}

struct SetButtonsView: View {
    @Binding var sets: [ExerciseSet]

    let completeSet: (Binding<ExerciseSet>, ScrollViewProxy, Bool) -> Void

    let buttonWidth: CGFloat = 40
    let buttonSpacing: CGFloat = 4

    private let setsMaxWidth: CGFloat
    @State private var dummySet: ExerciseSet = ExerciseSet(
        id: 0, setNumber: 0, weight: 0, reps: 0, isCompleted: true)

    init(
        sets: Binding<[ExerciseSet]>,
        completeSet: @escaping (Binding<ExerciseSet>, ScrollViewProxy, Bool) ->
            Void
    ) {
        self._sets = sets
        self.setsMaxWidth = 155  // (buttonWidth * 3) + (buttonSpacing * 2)
        self.completeSet = completeSet
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(
                        Array(0..<(max(0, 3 - sets.count))), id: \.self
                    ) { index in
                        Button(action: {
                        }) {
                            SetButtonContentView(
                                set: $dummySet,
                                buttonWidth: self.buttonWidth)
                        }
                        .hidden()
                    }

                    ForEach($sets) { $set in
                        SetButtonContentView(
                            set: $set, buttonWidth: self.buttonWidth
                        )
                        .onTapGesture(count: 2) {
                            completeSet($set, proxy, true)
                        }
                        .onTapGesture {
                            completeSet($set, proxy, false)
                        }
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    completeSet($set, proxy, true)
                                }
                        )
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(6)
                        .foregroundColor(Color.secondary)
                        .font(.footnote)
                        .id(set.id)
                    }
                }
            }
        }
        .frame(maxWidth: setsMaxWidth)
    }

}

#Preview {
    var sets = [
        ExerciseSet(
            id: 1, setNumber: 1, weight: 100, reps: 10, isCompleted: true),
        ExerciseSet(
            id: 2, setNumber: 2, weight: 220, reps: 10, isCompleted: false),
        ExerciseSet(
            id: 3, setNumber: 3, weight: 333, reps: 10, isCompleted: false),
        ExerciseSet(
            id: 3, setNumber: 4, weight: 333, reps: 10, isCompleted: false),
    ]

    SetButtonsView(
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
