import SwiftUI
import Combine

struct FixedCommaModifier: ViewModifier {
    @State private var value: String = ""
    
    func body(content: Content) -> some View {
        content
            .keyboardType(.decimalPad)
            .onReceive(Just(value)) { newValue in
                let filtered = newValue.filter { "0123456789.".contains($0) }
                if filtered != newValue {
                    self.value = filtered
                }
            }
            .onAppear {
                self.value = ""
            }
    }
}
