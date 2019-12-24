//
//  AccessoryViewController.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 22.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Cocoa

class AccessoryViewController: NSViewController {

    var exportType: MTLTextureManager.ExportType = .texture

    @IBAction func selectFormatAction(_ sender: NSPopUpButton) {
        self.exportType = MTLTextureManager.ExportType.allCases[sender.indexOfSelectedItem]
    }
    
}
