import Foundation
import ClangNotifications
import FirebaseMessaging

extension Clang.ClangNotification: Encodable {
  enum CodingKeys: String, CodingKey {
    case id
    case category
    case type
    case title
    case message
    case actions
    case customFields
  }
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(category, forKey: .category)
    try container.encode(type, forKey: .type)
    try container.encode(title, forKey: .title)
    try container.encode(message, forKey: .message)
    try container.encode(actions, forKey: .actions)
    try container.encode(customFields, forKey: .customFields)
  }
}

enum MyError: Error {
  case incorrectData
}

@objc(ClangNotificationModule)
class ClangNotificationModule: NSObject {

  let clang = Clang()
  let encoder = JSONEncoder()

  @objc
  func registerAccount(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      guard let firebaseToken = self.getFirebaseToken() else {
        reject("ERROR", "no token", NSError(domain: "", code: 200, userInfo: nil))
        return
      }

      self.clang.registerAccount(fcmToken: firebaseToken) { id, error in
        guard error == nil else {
          reject("ERROR", "no token", error)
          return
        }

        resolve(id)
      }
    }
  }

  @objc
  func logEvent(
    _ title: NSString,
    eventData: NSDictionary,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let eventData = eventData as? [String: String] else {
      reject("ERROR", "no data", NSError(domain: "", code: 200, userInfo: nil))
      return
    }

    clang.logEvent(eventName: title as String, eventData: eventData) { error in
      guard error == nil else {
        reject("ERROR", "no data", error)
        return
      }

      resolve("Sent event!")
    }
  }

  @objc
  func logNotification(
    _ notificationId: NSString,
    actionId: NSString,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    clang.logNotification(notificationId: notificationId as String, actionId: actionId as String) { error in
      guard error == nil else {
        reject("ERROR", "no data", error)
        return
      }

      resolve("Successfully logged notification")
      return
    }
  }

  private func getFirebaseToken() -> String? {
    Messaging.messaging().fcmToken
  }

  @objc
  func updateTokenOnServer(
    _ fcmToken: String,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    clang.updateTokenOnServer(fcmToken: fcmToken) { error in
      if let error = error {
        rejecter("event_failure", "an \(error) error occured", error)
      }
      else {
        resolver("Success")
      }
    }
  }

  @objc
  func updateProperties(
    _ data: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    guard let data = data as? [String: String] else {
      rejecter("event_failure", "data has incorrect format", MyError.incorrectData)
      return
    }
    clang.updateProperties(data: data) { error in
      if let error = error {
        rejecter("event_failure", "an \(error) error occured", error)
      }
      else {
        resolver("Success")
      }
    }
  }

  @objc
  func createNotification(
    _ userInfo: NSDictionary,
    resolver: RCTPromiseResolveBlock,
    rejecter: RCTPromiseRejectBlock
  ) {
    guard let userInfo = userInfo as? [AnyHashable:Any] else {
      rejecter("event_failure", "user info has incorrect format", MyError.incorrectData)
      return
    }
    do {
      let notification = try clang.createNotification(userInfo: userInfo)
      let jsonData = try encoder.encode(notification)
      let jsonString = String(data: jsonData, encoding: .utf8)!
      resolver(jsonString)
    }
    catch Clang.ClangError.missingFieldError(let field) {
      rejecter("event_failure", "missing field \(field)", Clang.ClangError.missingFieldError(field: field))
    }
    catch {
      rejecter("event_failure", "unexpected error", error)
    }
  }

  @objc
  func isClangNotification(
    _ userInfo: NSDictionary,
    resolver: RCTPromiseResolveBlock,
    rejecter: RCTPromiseRejectBlock
  ) {
    guard let userInfo = userInfo as? [AnyHashable:Any] else {
      rejecter("event_failure", "user info has incorrect format", MyError.incorrectData)
      return
    }

    let result = clang.isClangNotification(userInfo: userInfo)
    resolver(result)
  }

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
