//
//  Renderer.swift
//  BrickBreaker
//
//  Created by Iris Burmistrov on 25/04/2023.
//

import Foundation
import MetalKit

class Renderer: NSObject {
  let device: MTLDevice
  let commandQueue: MTLCommandQueue

  var upperVertices: [Float] = [
    -1, -1, 0,
    1, 1, 0,
    -1, 1, 0
  ]

  var lowerVertices: [Float] = [
    -1, -1, 0,
    1, -1, 0,
    1, 1, 0
  ]

  var pipelineState: MTLRenderPipelineState?
  var upperVertexBuffer: MTLBuffer?
  var lowerVertexBuffer: MTLBuffer?

  init (device: MTLDevice) {
    self.device = device
    commandQueue = device.makeCommandQueue()!
    super.init()
    buildModel()
    buildPipelineState()
  }

  private func buildModel() {
    upperVertexBuffer = device.makeBuffer(bytes: upperVertices,
                                     length: upperVertices.count * MemoryLayout<Float>.size, options: [])
    lowerVertexBuffer = device.makeBuffer(bytes: lowerVertices,
                                          length: lowerVertices.count * MemoryLayout<Float>.size, options: [])
  }

  private func buildPipelineState() {
    let library = device.makeDefaultLibrary()
    let vertexFunction = library?.makeFunction(name: "vertex_shader")
    let fragmentFunction = library?.makeFunction(name: "fragment_shader")

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error as NSError {
      print("error: \(error.localizedDescription)")
    }
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

  }

  /// called every frame.
  func draw(in view: MTKView) {
    guard let drawable = view.currentDrawable,
          let pipelineState = pipelineState,
      let descriptor = view.currentRenderPassDescriptor else {
      return
    }

    let commandBuffer = commandQueue.makeCommandBuffer()!
    let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!

    commandEncoder.setRenderPipelineState(pipelineState)
    commandEncoder.setVertexBuffer(upperVertexBuffer, offset: 0, index: 0)
    commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: upperVertices.count)
    commandEncoder.setVertexBuffer(lowerVertexBuffer, offset: 0, index: 0)
    commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: upperVertices.count)
    commandEncoder.endEncoding()
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
