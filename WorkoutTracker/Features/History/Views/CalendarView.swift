import SwiftUI
import UIKit

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @Binding var dateSelected: DateComponents?
    let displayEvents: [Date]
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = Calendar(identifier: .gregorian)
        view.availableDateRange = interval
        view.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.events = displayEvents
        // Reload decorations for visible range or specific dates if needed.
        // For simplicity, we can let the delegate handle it, but reloadDecorations is better for updates.
        // Getting all components from dates:
        let components = displayEvents.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        uiView.reloadDecorations(forDateComponents: components, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        var events: [Date] = []
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            
            // Check if any event matches this date
            // Optimization: Normalize dates to start of day for comparison
            let hasEvent = events.contains { eventDate in
                Calendar.current.isDate(eventDate, inSameDayAs: date)
            }
            
            if hasEvent {
                return .default(color: .systemBlue, size: .medium)
            }
            return nil
        }
    }
}
