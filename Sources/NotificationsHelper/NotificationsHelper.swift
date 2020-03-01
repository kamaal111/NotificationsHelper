import UserNotifications

/// This protocol gives guidlines to create a notification.
@available(tvOS, unavailable)
public protocol Notifiable {

    /// Identifiable id.
    var id: UUID { get } // swiftlint:disable:this identifier_name

    /// Notification titel.
    var title: String { get set }

    /// Notification body.
    var body: String { get set }

    /// Notification subtitle.
    var subtitle: String { get set }

    /// Notification badge count.
    var badge: NSNumber { get set }

    /// Notification sound.
    @available(iOS 10.0, OSX 10.14, watchOS 3.0, *)
    var sound: UNNotificationSound? { get set }

    /// Notification meta data.
    var userInfo: [String: String] { get set }

    /// Notification category identifier.
    var categoryIdentifier: String { get set }

    /// Notification attachment path.
    var attachment: String? { get set }

    /// Notification attachment identifier.
    var attachmentIdentifier: String? { get set }
}

/// A helper struct with all the methods you need to create a user notification.
@available(iOS 10.0, OSX 10.14, tvOS 10.0, watchOS 3.0, *)
@available(tvOS, unavailable)
public struct NotificationsHelper {

    public init() {}

    private var notifications = [Notifiable]()

    /// This function checks if user has granted permission to get notifications.
    /// ~~~
    /// // Usage
    /// let notificationsHelper = NotificationsHelper()
    /// notificationsHelper.requestPermission(for: [.alert, .sound, .badge])
    /// ~~~
    /// - Parameters:
    ///     - authorization: provide `UNAuthorizationOptions`. By default it is `[]`.
    /// - Returns: `void`
    public func requestPermission(for authorization: UNAuthorizationOptions = []) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
            options: authorization) { (permissionGranted, error) in
                guard let checkedError = error else {
                    if !permissionGranted {
                        print("Notification permission denied")
                    } else {
                        print("Notification permission granted")
                    }
                    return
                }
                print("ERROR:::", checkedError.localizedDescription)
        }
    }

    ///  This function adds a notification to the notifications array
    ///  - Parameters:
    ///       - notification: provide a `Notifiable` type to *notification*
    ///  - Returns: `void`
    public mutating func addNotification(_ notification: Notifiable) {
        notifications.append(notification)
    }

    /// This function schedules a notification for a certain time interval
    /// - Precondition: Must add a notification to the notifications array
    /// - Parameters:
    ///      - timeInterval: *timeInterval* to schedule notification
    ///      - repeats: if notification should repeat
    /// Returns: `void`
    public func scheduleNotifications(timeInterval: Double, repeats: Bool) {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getNotificationSettings(completionHandler: {(settings: UNNotificationSettings) in
            if settings.authorizationStatus != .authorized { return }
            for notification in self.notifications {
                let content = UNMutableNotificationContent()
                content.userInfo = notification.userInfo
                content.title = notification.title
                content.body = notification.body
                content.subtitle = notification.subtitle
                content.sound = notification.sound
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
                let request = UNNotificationRequest(
                    identifier: notification.id.uuidString,
                    content: content,
                    trigger: trigger)

                notificationCenter.add(request, withCompletionHandler: { (error: Error?) in
                    if let error = error {
                        print("ERROR:::", error.localizedDescription)
                        return
                    }
                    print("Scheduling notification with id: \(notification.id)")
                })
            }
        })
    }
}
