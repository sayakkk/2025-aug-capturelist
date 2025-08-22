import SwiftUI
import Photos

struct ScreenshotCard: View {
    let screenshot: Screenshot
    let size: CGSize
    
    @State private var thumbnailImage: UIImage?
    @State private var showingReminderAlert = false
    @State private var selectedDate = Date()
    
    private let screenshotManager = ScreenshotManager.shared
    
    var body: some View {
        ZStack {
            if let thumbnailImage = thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size.width, height: size.height)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            }
        }
        .onAppear {
            loadThumbnail()
        }
        .onLongPressGesture {
            showingReminderAlert = true
        }
        .alert("Schedule Reminder", isPresented: $showingReminderAlert) {
            DatePicker("Reminder Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
            Button("Schedule") {
                scheduleReminder()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Set a reminder for this screenshot")
        }
        .draggable(screenshot) {
            ScreenshotDragPreview(screenshot: screenshot, size: size)
        }
    }
    
    private func loadThumbnail() {
        if let thumbnailData = screenshot.thumbnailData,
           let image = UIImage(data: thumbnailData) {
            thumbnailImage = image
        } else {
            // Fallback to Photos API
            screenshotManager.getImage(for: screenshot, targetSize: size) { image in
                DispatchQueue.main.async {
                    thumbnailImage = image
                }
            }
        }
    }
    
    private func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Screenshot Reminder"
        content.body = "You have a screenshot reminder"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: selectedDate
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: "screenshot-\(screenshot.id?.uuidString ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Reminder scheduled for \(selectedDate)")
            }
        }
    }
}

struct ScreenshotDragPreview: View {
    let screenshot: Screenshot
    let size: CGSize
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.blue.opacity(0.8))
            .frame(width: size.width * 0.8, height: size.height * 0.8)
            .overlay(
                VStack {
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                        .font(.title2)
                    Text("Screenshot")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            )
    }
}

#Preview {
    let context = CoreDataManager.shared.viewContext
    let screenshot = Screenshot(context: context)
    screenshot.id = UUID()
    screenshot.assetIdentifier = "test"
    screenshot.capturedAt = Date()
    
    return ScreenshotCard(screenshot: screenshot, size: CGSize(width: 150, height: 150))
        .environment(\.managedObjectContext, context)
} 