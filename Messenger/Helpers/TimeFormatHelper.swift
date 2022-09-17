//
//  TimeFormatHelper.swift
//  Messenger
//
//  Created by Ngô Hải Đăng on 08/09/2022.
//

import Foundation

class TimeFormatHelper {
    static func string(for date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    static func chatString(for date: Date) -> String {
        let calendar = NSCalendar.current
        if calendar.isDateInToday(date) {
            return self.string(for: date, format: "HH:mm")
        }
        return self.string(for: date, format: "MMM dd")
    }
}
