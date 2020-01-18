import UserNotifications

struct NotificationsHelper {
    var text = "Hello, World!"
}

/// This struct represents a notification
public struct Notification: Identifiable {
    /// Identifiable id
    public let id = UUID()
    /// Notification title
    var title: String
    /// Notification body
    var body: String
    /// Notification sub title
    var subTitle: String
    /// Notification badge count
    var badge: NSNumber
    /// Notification meta data
    var userInfo: [String: String]
    /// Notification category identifier
    var categoryIdentifier: String
    /// Notification attachment path
    var attachment: String?
    /// Notification attachment identifier
    var attachmentIdentifier: String?
}

/**
 * A helper struct with all the methods you need to create a notification
 */
@available(iOS 10.0, *)
public struct LocalNotificationManager {
    private var notifications = [Notification]()

    /**
     * This function checks if user has granted permission to get notifications
     * - Returns: `void`
     */
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: { (permissionGranted, error) in
                guard let checkedError = error else {
                    if !permissionGranted { print("Notification permission denied")}
                    else { print("Notification permission granted") }
                    return
                }
                print("ERROR:::", checkedError.localizedDescription)
        })
    }

    /**
     * This function adds a notification to the initial notifications array
     * - Parameters:
     *      - notification: provide a `Notification` type to *notification*
     * - Returns: `void`
     */
    mutating func addNotification(notification: Notification) {
        notifications.append(notification)
    }

    /**
     * This function schedules a notification for a certain time interval
     * - Precondition: Must add a notification to the notifications array
     * - Parameters:
     *      - timeInterval: *timeInterval* to schedule notification
     * - Returns: `void`
     */
    func scheduleNotifications(timeInterval: Double, repeats: Bool) {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getNotificationSettings(completionHandler: {(settings) in
            if settings.authorizationStatus == .authorized {
                for notification in self.notifications {
                    let content = UNMutableNotificationContent()
                    content.userInfo = notification.userInfo
                    content.title = notification.title
                    content.body = notification.body
                    content.subtitle = notification.subTitle
                    content.sound = UNNotificationSound.default
                    content.categoryIdentifier = notification.categoryIdentifier
                    content.badge = notification.badge

                    if let attachment = notification.attachment,
                        let attachmentIdentifier = notification.attachmentIdentifier {
                        let url = URL(fileURLWithPath: attachment)
                        do {
                            let constructedAttachment = try UNNotificationAttachment(
                                identifier: attachmentIdentifier,
                                url: url, options: nil
                            )
                            content.attachments = [constructedAttachment]
                        } catch {
                            print("Couldn't attach attachment to notification")
                        }
                    }

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
                    let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)

                    notificationCenter.add(request, withCompletionHandler: { (error) in
                        if let error = error {
                            print("ERROR:::", error.localizedDescription)
                            return
                        }
                        print("Scheduling notification with id: \(notification.id)")
                    })
                }
            }
        })
    }
}