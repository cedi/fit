//
//  SetDetailView.swift
//  fit
//
//  Created by Cedric Kienzler on 10.01.25.
//


import SwiftUI

struct SetDetailView: View {
    @Binding var sets: [ExerciseSet]

    let completeSet: (Binding<ExerciseSet>, ScrollViewProxy) -> Void

    let buttonWidth: CGFloat = 40
    let buttonSpacing: CGFloat = 4

    @State private var setsWidth: CGFloat = 0
    private let setsMaxWidth: CGFloat

    init(
        sets: Binding<[ExerciseSet]>,
        completeSet: @escaping (Binding<ExerciseSet>, ScrollViewProxy) -> Void
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
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach($sets) { $set in
                            Button(action: {
                                completeSet($set, proxy)
                            }) {
                                HStack(spacing: 4) {
                                    Image(
                                        systemName: set.isCompleted
                                            ? "checkmark.circle.fill" : "circle"
                                    )
                                    .foregroundColor(Color.accentColor)
                                    .font(.headline)

                                    Text("Set \(set.setNumber):").bold()
                                        .strikethrough(
                                            set.isCompleted)

                                    if set.weight == 0 {
                                        Text("\(set.reps) reps").strikethrough(
                                            set.isCompleted
                                        ).bold(false)
                                    } else {
                                        Text(
                                            "\(set.reps) reps @ \(set.weight) kg"
                                        )
                                        .strikethrough(set.isCompleted).bold(
                                            false)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())  // Remove default button styling
                            .padding(.horizontal, 4)  // Padding only on left and right
                            .font(.headline)
                        }
                    }
                }
            }
            .frame(maxHeight: 75)

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
        }
    }
}

struct SetDetailsPreviewWrapper: View {
    @State var sets = [
        ExerciseSet(id: 1, setNumber: 1, weight: 100, reps: 10, isCompleted: true),
        ExerciseSet(id: 2, setNumber: 2, weight: 220, reps: 10, isCompleted: false),
        ExerciseSet(id: 3, setNumber: 3, weight: 333, reps: 10, isCompleted: false)
    ]

    var body: some View {
        SetDetailView(sets: $sets, completeSet: { set, _ in
            // Example action: Toggle completion
            if let index = sets.firstIndex(where: { $0.id == set.id }) {
                withAnimation {
                    sets[index].isCompleted.toggle()
                }
            }
        })
    }
}

#Preview {
    SetButtonsPreviewWrapper()
}
