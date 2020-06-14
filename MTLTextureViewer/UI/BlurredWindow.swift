import Cocoa

class BluredWindow: NSWindow {

    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.appearance = NSAppearance(named: .vibrantDark)
    }
}
