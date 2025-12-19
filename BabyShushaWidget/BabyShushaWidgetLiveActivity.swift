//
//  BabyShushaWidgetLiveActivity.swift
//  BabyShushaWidget
//
//  Created by  Igor Provorov on 15.12.25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BabyShushaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BabyShushaWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BabyShushaWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BabyShushaWidgetAttributes {
    fileprivate static var preview: BabyShushaWidgetAttributes {
        BabyShushaWidgetAttributes(name: "World")
    }
}

extension BabyShushaWidgetAttributes.ContentState {
    fileprivate static var smiley: BabyShushaWidgetAttributes.ContentState {
        BabyShushaWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BabyShushaWidgetAttributes.ContentState {
         BabyShushaWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BabyShushaWidgetAttributes.preview) {
   BabyShushaWidgetLiveActivity()
} contentStates: {
    BabyShushaWidgetAttributes.ContentState.smiley
    BabyShushaWidgetAttributes.ContentState.starEyes
}
