import AppKit

final class CenteringClipView: NSClipView {
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var constrainedClipViewBounds = super.constrainBoundsRect(proposedBounds)

        guard let documentView = self.documentView
        else { return constrainedClipViewBounds }

        if documentView.frame.width < proposedBounds.width {
            constrainedClipViewBounds.origin.x = floor((proposedBounds.width - documentView.frame.width) / -2)
        }

        if documentView.frame.height < proposedBounds.height {
            constrainedClipViewBounds.origin.y = floor((proposedBounds.height - documentView.frame.height) / -2)
        }

        return constrainedClipViewBounds
    }
}

