//
//  NSImage+Extensions.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 21.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Cocoa

extension NSImage {

    var height: CGFloat {
        return self.size.height
    }

    var width: CGFloat {
        return self.size.width
    }

    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation)
        else { return nil }

        return bitmapImage.representation(using: .png,
                                          properties: [:])
    }

    var cgImage: CGImage? {
        return self.cgImage(forProposedRect: nil,
                            context: nil,
                            hints: nil)
    }

    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage,
                  size: .init(width: cgImage.width,
                              height: cgImage.height))
    }

}
