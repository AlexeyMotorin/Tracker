import Foundation

struct TrackerCategory {
    let title: String
}

extension TrackerCategory: Equatable {
    static func == (lrh: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lrh.title == rhs.title ? true : false
    }
}
