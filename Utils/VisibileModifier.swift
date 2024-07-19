import SwiftUI

struct VisibleModifier: ViewModifier {
    @Binding var visibleExpenseIds: Set<UUID>
    let expenseId: UUID

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: VisiblePreferenceKey.self, value: geometry.frame(in: .global))
                }
            )
            .onPreferenceChange(VisiblePreferenceKey.self) { frame in
                DispatchQueue.main.async {
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let window = windowScene?.windows.first

                    let topSafeAreaHeight = window?.safeAreaInsets.top ?? 0
                    let navigationBarHeight: CGFloat = 44
                    let totalTopOffset = topSafeAreaHeight + navigationBarHeight

                    let bottomSafeAreaHeight = window?.safeAreaInsets.bottom ?? 0
                    let bottomOffset: CGFloat = bottomSafeAreaHeight

                    let screenBounds = UIScreen.main.bounds
                    let visibleRect = CGRect(
                        x: screenBounds.origin.x,
                        y: screenBounds.origin.y + totalTopOffset,
                        width: screenBounds.width,
                        height: screenBounds.height - totalTopOffset - bottomOffset
                    )

                    let isVisible = visibleRect.intersects(frame)
                    if isVisible {
                        visibleExpenseIds.insert(expenseId)
                    } else {
                        visibleExpenseIds.remove(expenseId)
                    }
                }
            }
    }
}

struct VisiblePreferenceKey: PreferenceKey {
    typealias Value = CGRect
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    func trackVisibility(visibleExpenseIds: Binding<Set<UUID>>, expenseId: UUID) -> some View {
        self.modifier(VisibleModifier(visibleExpenseIds: visibleExpenseIds, expenseId: expenseId))
    }
}
