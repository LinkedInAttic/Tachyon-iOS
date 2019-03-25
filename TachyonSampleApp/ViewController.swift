import UIKit

class ViewController: UIViewController {

    // MARK: - Static

    private static let lightGrayBackgroundColor = UIColor(displayP3Red: 225/255, green: 223/255, blue: 238/255, alpha: 1.0)

    /**
     The view config for our date picker.
     */
    private static var datePickerConfig: TCNDatePickerConfig {
        let config = TCNDatePickerConfig()
        config.selectedColor = .blue
        config.backgroundColor = lightGrayBackgroundColor
        config.weekendTextColor = .lightGray
        return config
    }

    /**
     The view config for our day view.
     */
    private static var dayViewConfig: TCNDayViewConfig {
        let config = TCNDayViewConfig()
        config.selectedEventColor = .blue
        config.selectedEventTextColor = .white
        config.cancelButtonImage = UIImage(named: "ic_cancel_16dp")
        config.customAllDayViewConfig = { (view) in
            view.layer.borderColor = lightGrayBackgroundColor.cgColor
            view.layer.borderWidth = 1.0
        }
        return config
    }

    // MARK: - Properties

    var currentDate: Date = Date()

    private var createdEvents: [TCNEvent] = []
    private let datePicker: TCNDatePickerView = TCNDatePickerView(frame: CGRect.zero, config: ViewController.datePickerConfig)
    private let dayView: TCNDayView = TCNDayView(frame: CGRect.zero, config: ViewController.dayViewConfig)

    /**
     Returns the view's frame accounting for its `safeAreaInsets`.
     */
    private var viewSafeAreaRect: CGRect {
        return CGRect(
            x: view.safeAreaInsets.left,
            y: view.safeAreaInsets.top,
            width: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: view.frame.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerDelegate = self
        view.addSubview(datePicker)

        // update day view
        dayView.delegate = self;
        dayView.dataSource = self;
        view.addSubview(dayView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Set the current date
        dayView.reload(resetScrolling: true)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        datePicker.frame = CGRect(
            x: viewSafeAreaRect.minX,
            y: viewSafeAreaRect.minY,
            width: viewSafeAreaRect.width,
            height: TCNDatePickerView.heightRequired(for: ViewController.datePickerConfig))

        dayView.frame = CGRect(
            x: viewSafeAreaRect.minX,
            y: datePicker.frame.maxY,
            width: viewSafeAreaRect.width,
            height: viewSafeAreaRect.height - datePicker.frame.height)
    }

    /**
     Called when the application comes into the foreground.
     Resets the `ViewController` state.
     */
    @objc
    private func applicationDidBecomeActive() {
        currentDate = Date()
        createdEvents = []
    }

}

// MARK: - TCNDatePickerDelegate

extension ViewController: TCNDatePickerDelegate {

    func datePickerView(_ datePickerView: TCNDatePickerView, didSelect date: Date) {
        currentDate = date

        // When a new date is selected, we'll update the dayView.
        dayView.reload(resetScrolling: false)
    }

}

// MARK: - TCNDayViewDelegate

extension ViewController: TCNDayViewDelegate {

    func dayView(_ dayView: TCNDayView, didSelectAvailabilityWith event: TCNEvent) {
        if createdEvents.contains(where: { $0.startDateTime == event.startDateTime }) {
            return
        }
        createdEvents.append(event)
        dayView.reload(resetScrolling: false)

        print("Selected time: \(ViewController.displayText(for: event))")
    }

    func dayView(_ dayView: TCNDayView, didCancel event: TCNEvent) {
        createdEvents.removeAll { (createdEvent) -> Bool in
            event == createdEvent
        }
        dayView.reload(resetScrolling: false)
    }

    private static func displayText(for event: TCNEvent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, d MMM yyyy")
        let dateString = dateFormatter.string(from: event.startDateTime)

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale.current
        timeFormatter.timeStyle = .short
        let startTimeString = timeFormatter.string(from: event.startDateTime)
        let endTimeString = timeFormatter.string(from: event.endDateTime)

        let timeZoneString = event.timezone?.localizedName(for: .shortStandard, locale: Locale.current)
            ?? TimeZone.current.localizedName(for: .shortStandard, locale: Locale.current)
            ?? ""
        return "\(dateString) from \(startTimeString) to \(endTimeString) (\(timeZoneString))"
    }

}

// MARK: - TCNDayViewDataSource

extension ViewController: TCNDayViewDataSource {

    var dayEvents: [TCNEvent] {
        return (getSampleEvents(for: currentDate) + createdEvents(for: currentDate)).filter { !$0.isAllDay }
    }

    var allDayEvents: [TCNEvent] {
        return (getSampleEvents(for: currentDate) + createdEvents(for: currentDate)).filter { $0.isAllDay }
    }

    private func createdEvents(for date: Date) -> [TCNEvent] {
        return createdEvents.filter { $0.occurs(onDay: date) }
    }

    /**
     Let's return a few different event sets for each day of the week.

     This only works for the Gregorian calendar!
     */
    private func getSampleEvents(for date: Date) -> [TCNEvent] {
        let components = Calendar(identifier: .gregorian).dateComponents(in: TimeZone.current, from: date)
        switch (components.weekday) {
        case 1:
            return SampleEvents.sunday(date)
        case 2:
            return SampleEvents.monday(date)
        case 3:
            return SampleEvents.tuesday(date)
        case 4:
            return SampleEvents.wednesday(date)
        case 5:
            return SampleEvents.thursday(date)
        case 6:
            return SampleEvents.friday(date)
        case 7:
            return SampleEvents.saturday(date)
        default:
            return []
        }
    }

}

