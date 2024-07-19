import Foundation

extension Array where Element: Identifiable {
    func isLastItem(_ item: Element) -> Bool {
        guard let itemIndex = self.firstIndex(where: { $0.id == item.id }) else {
            return false
        }
        let lastIndex = self.index(before: self.endIndex)
        return itemIndex == lastIndex
    }
}
