//
//  ViewController.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 20.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Cocoa
import Alloy
import MetalKit

class ViewController: NSViewController {

    // MARK: - IB

    @IBOutlet var mtkView: MTKView!
    @IBOutlet var scrollView: NSScrollView!

    // MARK: - Properties
    
    var context: MTLContext!
    var renderer: Renderer!
    var textureManager: MTLTextureManager!
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        do { try self.setup() }
        catch { displayAlert(message: "ViewController setup failed, error: \(error)") }
    }

    // MARK: - Setup

    func setup() throws {
        self.context = .init()

        self.mtkView.translatesAutoresizingMaskIntoConstraints = false
        Renderer.configure(self.mtkView,
                           with: self.context.device)

        self.renderer = try .init(context: self.context)
        self.textureManager = .init(context: self.context)
    }

    // MARK: - Draw

    func drawTexture() throws {
        guard let texture = self.textureManager.texture
        else { throw MTLTextureManager.Error.textureDataIsMissing }

        let textureSize = CGSize(width: texture.width,
                                 height: texture.height)
        self.mtkView.frame.size = textureSize
        self.mtkView.drawableSize = textureSize
        self.scrollView.magnify(toFit: NSRect(origin: .zero,
                                              size: textureSize))

        try self.context.scheduleAndWait { commandBuffer in
            self.renderer.draw(texture: texture,
                               on: self.mtkView,
                               in: commandBuffer)
        }
    }

}
