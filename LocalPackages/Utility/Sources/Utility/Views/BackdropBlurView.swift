//
//  BackdropBlurView.swift
//  Utility
//
//  Created by Igor Nikolaev on 26.06.2025.
//

/*
 Based on: [ https://stackoverflow.com/a/73950386 ]
 NOTE: For correct blur without artifacts, see Preview section.
 */

import SwiftUI

/// A transparent View that blurs its background
public struct BackdropBlurView: View {
  private let radius: CGFloat
  
  public init(radius: CGFloat) {
    self.radius = radius
  }
  
  public var body: some View {
    BackdropView()
      .blur(radius: radius)
  }
}

private struct BackdropView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIVisualEffectView {
    let blur = UIBlurEffect()
    let view = UIVisualEffectView()
    let animator = UIViewPropertyAnimator()
    animator.addAnimations { view.effect = blur }
    animator.fractionComplete = 0
    animator.stopAnimation(false)
    animator.finishAnimation(at: .current)
    return view
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


#Preview {
  let blurRadius: CGFloat = 10
  
  GeometryReader { proxy in
    ZStack(alignment: .leading) {
      Image(systemName: "globe")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(.cyan)
      
      HStack {
        let itemWidth = 0.3 * proxy.size.width
        
        // not blur at edges
        BackdropBlurView(radius: blurRadius)
          .frame(width: itemWidth)
          .border(.red.opacity(0.2))
        
        Spacer()
        
        // correct blur
        BackdropBlurView(radius: 0)
          .blur(radius: blurRadius, opaque: true)
          .frame(width: itemWidth)
          .border(.red.opacity(0.2))
      }
    }
  }
  .aspectRatio(1, contentMode: .fit)
  .border(.blue.opacity(0.2))
  .padding()
}
