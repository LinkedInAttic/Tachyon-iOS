import Foundation
import XCTest

class TCNEventTests: XCTestCase {

    func testDisplayTimeString() {
        let event1 = TCNEvent(
            name: "",
            startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date()),
            endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
            location: nil,
            timezone: nil,
            isAllDay: false)
        XCTAssertEqual(event1?.displayTimeString, "12:00 PM - 1:00 PM")

        let event2 = TCNEvent(
            name: "",
            startDateTime: TCNTestUtils.date(withTime: "1:00", onDay: Date(), daysToAdd: -1),
            endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
            location: nil,
            timezone: nil,
            isAllDay: false)
        XCTAssertEqual(event2?.displayTimeString, "1:00 AM - 1:00 PM")
    }

    func testOccursOnDay() {
        let event1 = TCNEvent(
            name: "",
            startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date()),
            endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
            location: nil,
            timezone: nil,
            isAllDay: false)
        XCTAssertTrue(event1?.occurs(onDay: Date()) ?? false)

        let event2 = TCNEvent(
            name: "",
            startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date(), daysToAdd: -1),
            endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
            location: nil,
            timezone: nil,
            isAllDay: false)
        XCTAssertTrue(event2?.occurs(onDay: Date()) ?? false)

        let event3 = TCNEvent(
            name: "",
            startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date()),
            endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date(), daysToAdd: 1),
            location: nil,
            timezone: nil,
            isAllDay: false)
        XCTAssertTrue(event3?.occurs(onDay: Date()) ?? false)

        let event4 = TCNEvent(
            name: "",
            startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date(), daysToAdd: -1),
            endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date(), daysToAdd: 1),
            location: nil,
            timezone: nil,
            isAllDay: false)
        XCTAssertTrue(event4?.occurs(onDay: Date()) ?? false)

        let event5 = TCNEvent(
            name: "",
            startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date(), daysToAdd: 1),
            endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date(), daysToAdd: 1),
            location: nil,
            timezone: nil,
            isAllDay: false)
        XCTAssertFalse(event5?.occurs(onDay: Date()) ?? true)
    }

    func testMergedEvents() {
        var mergedEvents = TCNEvent.mergedEvents(for: [
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "14:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false)
            ].compactMap { $0 })

        XCTAssertEqual(mergedEvents.count, 1)
        XCTAssertEqual(mergedEvents[0].startDateTime, TCNTestUtils.date(withTime: "12:00", onDay: Date()))
        XCTAssertEqual(mergedEvents[0].endDateTime, TCNTestUtils.date(withTime: "14:00", onDay: Date()))

        mergedEvents = TCNEvent.mergedEvents(for: [
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "12:30", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "14:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false)
            ].compactMap { $0 })

        XCTAssertEqual(mergedEvents.count, 2)

        mergedEvents = TCNEvent.mergedEvents(for: [
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "12:30", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "14:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false)
            ].compactMap { $0 })

        XCTAssertEqual(mergedEvents.count, 1)
        XCTAssertEqual(mergedEvents[0].startDateTime, TCNTestUtils.date(withTime: "12:00", onDay: Date()))
        XCTAssertEqual(mergedEvents[0].endDateTime, TCNTestUtils.date(withTime: "14:00", onDay: Date()))

        mergedEvents = TCNEvent.mergedEvents(for: [
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "12:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "13:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "12:30", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "14:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "12:30", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "16:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "17:30", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "18:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "18:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "19:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false),
            TCNEvent(
                name: "",
                startDateTime: TCNTestUtils.date(withTime: "17:00", onDay: Date()),
                endDateTime: TCNTestUtils.date(withTime: "20:00", onDay: Date()),
                location: nil,
                timezone: nil,
                isAllDay: false)
            ].compactMap { $0 })

        XCTAssertEqual(mergedEvents.count, 2)
        XCTAssertEqual(mergedEvents[0].startDateTime, TCNTestUtils.date(withTime: "12:00", onDay: Date()))
        XCTAssertEqual(mergedEvents[0].endDateTime, TCNTestUtils.date(withTime: "16:00", onDay: Date()))
        XCTAssertEqual(mergedEvents[1].startDateTime, TCNTestUtils.date(withTime: "17:00", onDay: Date()))
        XCTAssertEqual(mergedEvents[1].endDateTime, TCNTestUtils.date(withTime: "20:00", onDay: Date()))
    }

}
