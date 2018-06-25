# Matchmore iOS SDK

`Matchmore` is a contextualized publish/subscribe model which can be used to model any geolocated or proximity based mobile application. Save time and make development easier by using our SDK. We are built on Apple Core Location technologies and we also provide iBeacons compatibility.

## Versioning

SDK is written using Swift 4.1.

Matchmore SDK requires iOS 9+.

## Installation

Matchmore is available through [CocoaPods](http://cocoapods.org), simply add the following
line to your Podfile:

    pod 'Matchmore'
    
In case of any problems with cocoapods try

    pod repo update

## Usage

Please refer to documentation "tutorial" to get a full explanation on this example:

Setup application API key and world, get it for free from [http://matchmore.io/](http://matchmore.io/).
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let config = MatchmoreConfig(apiKey: "YOUR_API_KEY")
    Matchmore.configure(config)
    return true
}
```

Create first device, publication and subscription. Please note that we're not caring about errors right now.
```swift
Matchmore.startUsingMainDevice { _ in
    let publication = Publication(topic: "Test Topic", range: 20, duration: 100, properties: ["test": "true"])
    Matchmore.createPublicationForMainDevice(publication: publication, completion: { _ in
        print("🏔 Created Pub")
    })
    let subscription = Subscription(topic: "Test Topic", range: 20, duration: 100, selector: "test = 'true'")
    Matchmore.createSubscriptionForMainDevice(subscription: subscription, completion: { _ in
        print("🏔 Created Sub")
    })
}
```

Define an object that's `AlpsManagerDelegate` implementing `OnMatchClojure`.
```swift
class ExampleMatchHandler: MatchDelegate {
    var onMatch: OnMatchClosure?
    init(_ onMatch: @escaping OnMatchClosure) {
        self.onMatch = onMatch
    }
}
```

Start listening for main device matches changes.
```swift
let exampleMatchHandler = ExampleMatchHandler { matches, _ in
    print(matches)
}
Matchmore.matchDelegates += exampleMatchHandler
```

## Set up APNS: Certificates for push notifications

Matchmore iOS SDK uses Apple Push Notification Service (APNS) to deliver notifications to your iOS users.

If you already know how to enable APNS, don't forget to upload the certificate in our portal.

Also, you need to add the following lines to your project `AppDelegate`.

These callbacks allow the SDK to get the device token.

```swift
// Called when APNS has assigned the device a unique token
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Convert token to string
    let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    Matchmore.registerDeviceToken(deviceToken: deviceTokenString)
}

// Called when APNS failed to register the device for push notifications
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    Matchmore.processPushNotification(pushNotification: userInfo)
}
```

Else, you can find help on [how to setup APNS](https://github.com/matchmore/alps-ios-sdk/blob/master/ApnsSetup.md).

## Example

In `MatchmoreExample/` you will find working simple example.

For more complex solution please check [Ticketing App](https://github.com/matchmore/alps-ios-TicketingApp):

## Documentation

See the [http://matchmore.io/documentation/api](http://matchmore.io/documentation/api) or consult our website for further information [http://matchmore.io/](http://matchmore.io/)

## Authors

- @tharpa, rk@matchmore.com
- @wenjdu, jean-marc.du@matchmore.com
- @maciejburda, maciej.burda@matchmore.com


## License

`Matchmore` is available under the MIT license. See the LICENSE file for more info.
