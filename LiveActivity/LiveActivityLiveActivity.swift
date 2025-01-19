//
//  LiveActivityLiveActivity.swift
//  LiveActivity
//
//  Created by Cedric Kienzler on 18.01.25.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentExercise: String
        var currentSetReps: Int
        var currentSetWeight: Int
        var nextExercises: [String]
    }

    var name: String
}

struct LiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 4, alignment: .top),
                    GridItem(.flexible(), spacing: 4, alignment: .top),
                ], alignment: .leading, spacing: 4
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Now")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(context.state.currentExercise)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(
                        "\(context.state.currentSetReps) reps @ \(context.state.currentSetWeight) kg"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Button(action: {
                        print("Set Completed!")
                    }) {
                        Text("Complete Set")
                            .font(.subheadline)
                            .bold()
                            .padding(8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .activityBackgroundTint(Color(UIColor.systemGroupedBackground))
                .activitySystemActionForegroundColor(Color.accentColor)
                .alignmentGuide(.top) { _ in 0 }  // Align this VStack to the top

                VStack(alignment: .leading, spacing: 8) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ForEach(context.state.nextExercises.prefix(5), id: \.self) {
                        exercise in
                        HStack(alignment: .center) {
                            Image(systemName: "play.circle")
                            Text(exercise)
                        }
                        .font(.caption)
                    }
                }
                .padding()
                .activityBackgroundTint(Color(UIColor.systemGroupedBackground))
                .activitySystemActionForegroundColor(Color.accentColor)
                .alignmentGuide(.top) { _ in 0 }  // Align this VStack to the top
            }

        } dynamicIsland: { context in
            DynamicIsland {
                // **Expanded Dynamic Island**
                DynamicIslandExpandedRegion(.leading) {
                        Text("Now")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }

                    DynamicIslandExpandedRegion(.center) {
                        VStack(alignment: .center, spacing: 4) {
                            Text("\(context.state.currentSetReps) x \(context.state.currentSetWeight) kg")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)

                            Text(context.state.currentExercise)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }

                DynamicIslandExpandedRegion(.trailing) {
                    Button(action: {
                        print("Set Completed!")
                    }) {
                        Image(systemName: "checkmark")
                            .frame(width: 40, height: 50)
                            .font(.system(size: 30, weight: .semibold))
                    }
                    .padding(.trailing, 4) // Add spacing from the edge
                }

                    DynamicIslandExpandedRegion(.bottom) {
                        EmptyView()
                    }

            } compactLeading: {
                Text("\(context.state.currentExercise)")
            } compactTrailing: {
                Text(
                    "\(context.state.currentSetReps) x \(context.state.currentSetWeight) kg"
                )
            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(Color.accentColor)
            }
            .widgetURL(URL(string: "myapp://workout"))
            .keylineTint(Color.accentColor)
        }
    }
}

extension LiveActivityAttributes {
    fileprivate static var preview: LiveActivityAttributes {
        LiveActivityAttributes(name: "Workout")
    }
}

#Preview("Notification", as: .content, using: LiveActivityAttributes.preview) {
    LiveActivityLiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState(
        //currentExercise: "Incline Dumbbell Press",
        currentExercise: "Bench Press",
        currentSetReps: 6,
        currentSetWeight: 100,
        nextExercises: [
            "Bench Press", "Face Pulls", "Tricep Pushdown", "Dumbell Pullover",
            "Lateral Raises", "Tricep Dips", "foo", "bar",
        ]
    )
}

#Preview(
    "Dynamic Island Expanded", as: .dynamicIsland(.expanded),
    using: LiveActivityAttributes.preview
) {
    LiveActivityLiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState(
        currentExercise: "Bench Press",
        currentSetReps: 6,
        currentSetWeight: 100,
        nextExercises: ["Bench Press", "Face Pulls", "Tricep Pushdown"]
    )
}

#Preview(
    "Dynamic Island Compact", as: .dynamicIsland(.compact),
    using: LiveActivityAttributes.preview
) {
    LiveActivityLiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState(
        currentExercise: "Bench Press",
        currentSetReps: 6,
        currentSetWeight: 100,
        nextExercises: ["Bench Press", "Face Pulls", "Tricep Pushdown"]
    )
}

#Preview(
    "Dynamic Island Minimal", as: .dynamicIsland(.minimal),
    using: LiveActivityAttributes.preview
) {
    LiveActivityLiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState(
        currentExercise: "Bench Press",
        currentSetReps: 6,
        currentSetWeight: 100,
        nextExercises: ["Bench Press", "Face Pulls", "Tricep Pushdown"]
    )
}
