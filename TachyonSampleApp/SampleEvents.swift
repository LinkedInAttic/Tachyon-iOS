import Foundation

/**
 Contains methods to retrieve a selection of sample events.
 */
enum SampleEvents {

    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
        return dateFormatter
    }()

    private static func dateWithTime(_ timeString: String, onDay day: Date, daysToAdd: Int = 0) -> Date {
        let time = dateFormatter.date(from: "2019-01-18 \(timeString)") ?? Date()
        let calendar = Calendar(identifier: .gregorian)
        let timeComponents = calendar.dateComponents(in: TimeZone.current, from: time)

        guard let hour = timeComponents.hour,
            let minute = timeComponents.minute,
            let second = timeComponents.second else {
                return Date()
        }
        let dayToUse = TCNDateUtil.date(byAddingDays: daysToAdd, to: day)

        return calendar.date(bySettingHour: hour, minute: minute, second: second, of: dayToUse) ?? Date()
    }

    /**
     Convenience method to coalesce a non-optional TCNEvent.
     */
    private static func event(name: String,
                              startDateTime: Date,
                              endDateTime: Date,
                              location: String?,
                              timezone: TimeZone?,
                              isAllDay: Bool) -> TCNEvent {
        return TCNEvent(
            name: name,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            location: location,
            timezone: timezone,
            isAllDay: isAllDay) ?? TCNEvent(name: name, startDateTime: startDateTime)
    }

    static func sunday(_ date: Date) -> [TCNEvent] {
        return [
            event(
                name: "Play Kingdom Hearts 1",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true),
            event(
                name: "Play Kingdom Hearts 2",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true),
            event(
                name: "Play Kingdom Hearts Birth By Sleep",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true),
            event(
                name: "Play Kingdom Hearts Dream Drop Distance",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true),
            event(
                name: "Play Kingdom Hearts 3",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true)
        ]
    }

    static func monday(_ date: Date) -> [TCNEvent] {
        return [
            event(
                name: "Drink coffees numbers 4-6",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("13:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Meeting",
                startDateTime: dateWithTime("12:30", onDay: date),
                endDateTime: dateWithTime("14:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Offsite!",
                startDateTime: dateWithTime("12:30", onDay: date),
                endDateTime: dateWithTime("06:00", onDay: date, daysToAdd: 1),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Fly in from Bora Bora",
                startDateTime: dateWithTime("8:30", onDay: date),
                endDateTime: dateWithTime("09:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false)
        ]
    }

    static func tuesday(_ date: Date) -> [TCNEvent] {
        return [
            event(
                name: "Offsite!",
                startDateTime: dateWithTime("12:30", onDay: date, daysToAdd: -1),
                endDateTime: dateWithTime("06:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Lounge",
                startDateTime: dateWithTime("8:30", onDay: date),
                endDateTime: dateWithTime("09:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Work",
                startDateTime: dateWithTime("9:30", onDay: date),
                endDateTime: dateWithTime("17:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false)
        ]
    }

    static func wednesday(_ date: Date) -> [TCNEvent] {
        return [
            event(
                name: "Eat breakfast cookies",
                startDateTime: dateWithTime("8:00", onDay: date),
                endDateTime: dateWithTime("9:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Eat lunch cereal",
                startDateTime: dateWithTime("12:30", onDay: date),
                endDateTime: dateWithTime("13:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Eat dinner potato chips",
                startDateTime: dateWithTime("18:00", onDay: date),
                endDateTime: dateWithTime("19:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Don't eat midnight snacks!",
                startDateTime: dateWithTime("18:00", onDay:date, daysToAdd: -1),
                endDateTime: dateWithTime("19:00", onDay: date, daysToAdd: -1),
                location: nil,
                timezone: nil,
                isAllDay: false)
        ]
    }

    static func thursday(_ date: Date) -> [TCNEvent] {
        return [
            event(
                name: "Go shopping for that titanium toothbrush stand you've always wanted. You deserve it!",
                startDateTime: dateWithTime("13:30", onDay: date),
                endDateTime: dateWithTime("16:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Silent dance party",
                startDateTime: dateWithTime("16:00", onDay: date),
                endDateTime: dateWithTime("19:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false)
        ]
    }

    static func friday(_ date: Date) -> [TCNEvent] {
        return [
            event(
                name: "Beer",
                startDateTime: dateWithTime("08:00", onDay: date),
                endDateTime: dateWithTime("10:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Beer",
                startDateTime: dateWithTime("10:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Beer",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("14:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Beer",
                startDateTime: dateWithTime("14:00", onDay: date),
                endDateTime: dateWithTime("16:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Beer",
                startDateTime: dateWithTime("16:00", onDay: date),
                endDateTime: dateWithTime("18:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Beer",
                startDateTime: dateWithTime("18:00", onDay: date),
                endDateTime: dateWithTime("20:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false),
            event(
                name: "Cognac",
                startDateTime: dateWithTime("20:00", onDay: date),
                endDateTime: dateWithTime("22:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false)
        ]
    }

    static func saturday(_ date: Date) -> [TCNEvent] {
        return [
            event(
                name: "Think",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true),
            event(
                name: "Discuss",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true),
            event(
                name: "Understand",
                startDateTime: dateWithTime("12:00", onDay: date),
                endDateTime: dateWithTime("12:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: true),
            event(
                name: "Ponder",
                startDateTime: dateWithTime("06:00", onDay: date),
                endDateTime: dateWithTime("22:00", onDay: date),
                location: nil,
                timezone: nil,
                isAllDay: false)
        ]
    }

}
