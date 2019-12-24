//
//  BlurredView.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 22.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Cocoa

class BlurredView: NSVisualEffectView {

    override func viewDidMoveToWindow() {
        self.material = .dark
        self.blendingMode = .behindWindow
        self.state = .active
    }

}
