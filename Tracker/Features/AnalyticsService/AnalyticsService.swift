import Foundation
import AppMetricaCore
import Logging

protocol AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent)
}

final class AnalyticsService: AnalyticsServiceProtocol {

    static let shared = AnalyticsService()

    private let logger = Logger(label: "AnalyticsService")

    private init() {}

    func report(event: AnalyticsEvent) {
        var parameters: [String: Any] = [
            "event": event.event,
            "screen": event.screen
        ]

        if let item = event.item {
            parameters["item"] = item.rawValue
        }

        AppMetrica.reportEvent(
            name: "user_action",
            parameters: parameters,
            onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            }
        )

        logEvent(event)
    }

    private func logEvent(_ event: AnalyticsEvent) {
        var metadata: Logger.Metadata = [
            "event": .string(event.event),
            "screen": .string(event.screen)
        ]

        if let item = event.item {
            metadata["item"] = .string(item.rawValue)
        }

        logger.info(
            "Analytics event sent",
            metadata: metadata
        )
    }
}

extension AnalyticsEvent {

    static func openMain() -> AnalyticsEvent {
        AnalyticsEvent(event: "open", screen: "Main", item: nil)
    }

    static func closeMain() -> AnalyticsEvent {
        AnalyticsEvent(event: "close", screen: "Main", item: nil)
    }

    static func click(item: AnalyticsItem) -> AnalyticsEvent {
        AnalyticsEvent(event: "click", screen: "Main", item: item)
    }
}
