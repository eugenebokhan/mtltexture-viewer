import Cocoa

func displayAlert(title: String = "Error",
                  message: String) {
    let alert = NSAlert()
    alert.messageText = message
    alert.informativeText = title
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
}
