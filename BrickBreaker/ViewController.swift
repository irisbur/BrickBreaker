//
//  ViewController.swift
//  BrickBreaker
//
//  Created by Iris Burmistrov on 25/04/2023.
//

import UIKit
import MetalKit

enum Colors {
  static let defaultGreen = MTLClearColor(red: 0.0, green: 0.4, blue: 0.21, alpha: 1.0)
}

class ViewController: UIViewController {

  var metalView: MTKView {
    return view as! MTKView
  }

  var device: MTLDevice!
  var renderer: Renderer?

  override func viewDidLoad() {
    super.viewDidLoad()
    metalView.device = MTLCreateSystemDefaultDevice()
    renderer = Renderer(device: metalView.device!)
    metalView.clearColor = Colors.defaultGreen
    metalView.delegate = renderer
  }
}

