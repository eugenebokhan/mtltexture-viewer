//
//  Utils.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 24.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

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
