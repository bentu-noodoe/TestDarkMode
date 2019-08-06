//
//  Date+Extensions.swift
//  TestDarkMode
//
//  Created by ZhengXun Tu on 2019/8/6.
//  Copyright © 2019 Noodoe. All rights reserved.
//

import Foundation

extension Date {

    public func ordinalDifference(of smaller: Calendar.Component, from date: Date, in larger: Calendar.Component) -> Int? {
        guard
            let this = Calendar.current.ordinality(of: smaller, in: larger, for: self),
            let other = Calendar.current.ordinality(of: smaller, in: larger, for: date)
            else {
                return nil
        }
        return this - other
    }

    public func numeralDifference(of component: Calendar.Component, from date: Date) -> Int? {
        guard
            let this = Calendar.current.dateComponents([component], from: self).value(for: component),
            let other = Calendar.current.dateComponents([component], from: date).value(for: component)
            else {
                return nil
        }
        return this - other
    }

    public func adding(_ quantity: Int, _ component: Calendar.Component) -> Date? {
        return Calendar.current.date(byAdding: component, value: quantity, to: self)
    }

    public func startOfMonth() -> Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
    }

    public func endOfMonth() -> Date? {
        guard let start = self.startOfMonth() else {
            return nil
        }
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: start)
    }

    public func nextHalfOrSharpHour() -> Date? {
        let halfComp = DateComponents(minute: 30)
        let sharpComp = DateComponents(minute: 0)
        guard
            let half = Calendar.current.nextDate(after: self, matching: halfComp, matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward),
            let sharp = Calendar.current.nextDate(after: self, matching: sharpComp, matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward)
            else {
                return nil
        }
        return min(half, sharp)
    }

    public func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    public func endOfDay() -> Date? {
        return Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay())
    }

}
