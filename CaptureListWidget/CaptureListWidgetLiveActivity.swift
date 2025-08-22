import ActivityKit
import WidgetKit
import SwiftUI

struct CaptureListWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CaptureListAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("CaptureList")
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
                    Text("Bottom")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
        }
    }
}

struct CaptureListAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var value: Int
    }

    var name: String
} 