//
//  ViewUtilities.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 8/2/24.
//

import SwiftUI

/// Style Related
func backgroundGradient(color: String) -> LinearGradient {
    switch color {
    case "blue":
        return LinearGradient(gradient: Gradient(colors: [Color(red: 146/255, green: 239/255, blue: 253/255), Color(red: 78/255, green: 101/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
    case "yellow":
        return LinearGradient(gradient: Gradient(colors: [Color(red: 251/255, green: 176/255, blue: 59/255), Color(red: 212/255, green: 20/255, blue: 90/255)]), startPoint: .top, endPoint: .bottom)
    case "green":
        return LinearGradient(gradient: Gradient(colors: [Color(red: 252/255, green: 238/255, blue: 33/255), Color(red: 0/255, green: 146/255, blue: 69/255)]), startPoint: .top, endPoint: .bottom)
    default:
        return LinearGradient(gradient: Gradient(colors: [Color(red: 146/255, green: 239/255, blue: 253/255), Color(red: 78/255, green: 101/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
    }
}

/// Offset Preference Key
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ScrollViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// offsetChange
extension View {
    @ViewBuilder
    func offsetChange(offset: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: OffsetKey.self, value: geometry.frame(in: .global))
                        .onPreferenceChange(OffsetKey.self) { value in
                            DispatchQueue.main.async {
                                let safeArea = getSafeAreaInsets()
                                let adjustedRect = CGRect(
                                    x: value.minX,
                                    y: value.minY - safeArea.top,
                                    width: value.width,
                                    height: value.height
                                )
                                offset(adjustedRect)
                            }
                        }
                }
            }
    }
    
    private func getSafeAreaInsets() -> UIEdgeInsets {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}

/// Orientation
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}