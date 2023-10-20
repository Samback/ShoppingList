import FirebaseAnalytics
import Firebase
import ComposableAnalytics

public extension AnalyticsClient {
  static var firebaseClient: Self {
    return .init(
      sendAnalytics: { analyticsData in
        switch analyticsData {
        case let .event(name: name, properties: properties):
          Firebase.Analytics.logEvent(name, parameters: properties)

        case .userId(let id):
          Firebase.Analytics.setUserID(id)

        case let .userProperty(name: name, value: value):
          Firebase.Analytics.setUserProperty(value, forName: name)

        case .screen(name: let name):
          Firebase.Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
          ])

        case .error(let error):
            Firebase.Analytics.logEvent("Error", parameters: [
                "error": error.localizedDescription
            ])
        }
      }
    )
  }
}
