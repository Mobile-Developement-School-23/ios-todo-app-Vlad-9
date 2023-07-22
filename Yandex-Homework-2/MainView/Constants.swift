import SwiftUI
enum Contstants {
    static let plusButtonImageName = "plus"
    static let plusButtonFrameSize: CGFloat = 44
    static let plusButtonRect = CGRect(x: 0,
                                       y: 0,
                                       width: 44,
                                       height: 44)
    static let plusButtonPointSize: CGFloat = 28
    static let plusButtonshadowRadius: CGFloat = 10
    static let plusButtonshadowOpacity: Float = 0.3
    static let plusButtonCornerRadius: CGFloat = 25
    // Table
    static var radius: CGFloat { return 16.0 }
    static var insets: EdgeInsets { return EdgeInsets(top: 0,
                                                      leading: 16,
                                                      bottom: 0,
                                                      trailing: 16) }
    static var separatorLeadingInster: CGFloat { return 36.0 }
    // Header
    static var sectionViewHeaderDefaultSpacing: CGFloat { return 0.0 }
    static var sectionViewTextFontSize: CGFloat { return 15.0 }
    static var sectionViewHeaderInsets: EdgeInsets { return EdgeInsets(top: 18,
                                                                       leading: 16,
                                                                       bottom: 12,
                                                                       trailing: 16) }
    // Cells
    static var cellDefaultSpacing: CGFloat { return 12.0 }
    /// Text
    static var textVerticalPadding: CGFloat { return 16.0 }
    static var textVerticalPaddingWithDeadline: CGFloat { return 12.0 }
    static var textLineLimit: Int { return 3 }
    /// deadline
    static var deadlineViewDefaultSpacing: CGFloat { return 2.0 }
    static var textWithDeadlineDefaultSpacing: CGFloat { return 0.0 }
    static var deadlineViewTextFontSize: CGFloat { return 15.0 }
    static var dateFormat: String { return "d MMM" }
    static var dateFormatExtended: String { return "d MMM YYYY" }
    ///  Priority image
    static var priorityImageDefaultSpacing: CGFloat { return 2.0 }
}
