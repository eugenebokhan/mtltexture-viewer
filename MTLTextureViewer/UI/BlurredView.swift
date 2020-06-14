import Cocoa

class BlurredView: NSVisualEffectView {

    override func viewDidMoveToWindow() {
        self.material = .dark
        self.blendingMode = .behindWindow
        self.state = .active
    }

}
