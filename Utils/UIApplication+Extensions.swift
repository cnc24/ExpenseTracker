import SwiftUI
import CoreData

extension UIApplication {
    func hideSidebar() {
        guard let splitViewController = windows.first?.rootViewController as? UISplitViewController else { return }
        splitViewController.dismiss(animated: true)
    }
}
