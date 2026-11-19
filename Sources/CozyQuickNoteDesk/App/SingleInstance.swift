import AppKit
import Darwin

/// Makes sure only one copy of the app runs at a time, however it was started:
/// from Applications, from the dist folder, from `swift run`, or at login.
/// Two copies would mean two menu bar icons and two fights over the same shortcut.
enum SingleInstance {
    /// Sent to the copy that is already running, asking it to show its room.
    static let showRoomNotification = Notification.Name("dev.cozy.QuickNoteDesk.showRoom")

    private static var lockDescriptor: Int32 = -1

    /// Call once, as early as possible. The first copy takes a lock that lasts as long as it runs
    /// (macOS releases it automatically if the app quits or crashes). A second copy asks the first
    /// one to show its window, then quits straight away, before it can create a menu bar icon.
    static func claimOrExit() {
        let folder = JSONNoteStore.defaultDirectory
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let path = folder.appendingPathComponent("instance.lock").path

        let descriptor = Darwin.open(path, O_CREAT | O_RDWR, 0o600)
        guard descriptor >= 0 else { return }            // can't lock: start anyway rather than refuse to run

        if flock(descriptor, LOCK_EX | LOCK_NB) == 0 {
            lockDescriptor = descriptor                  // keep it open for the life of the app
            return
        }

        close(descriptor)
        print("Cozy Quick-Note Desk is already running. Asking it to show its window, then exiting this copy.")
        DistributedNotificationCenter.default().postNotificationName(
            showRoomNotification, object: nil, userInfo: nil, deliverImmediately: true
        )
        exit(0)
    }
}
