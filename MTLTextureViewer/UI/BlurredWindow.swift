//
//  BlurredWindow.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 22.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Cocoa

class BluredWindow: NSWindow {

    override func awakeFromNib() {
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.appearance = NSAppearance(named: .vibrantDark)
    }
}
