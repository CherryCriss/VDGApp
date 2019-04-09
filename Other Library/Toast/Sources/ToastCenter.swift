import UIKit
open class ToastCenter {
  private let queue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  open var currentToast: Toast? {
    return self.queue.operations.first { !$0.isCancelled && !$0.isFinished } as? Toast
  }
  public static let `default` = ToastCenter()
  init() {
    #if swift(>=4.2)
    let name = UIDevice.orientationDidChangeNotification
    #else
    let name = UIDevice.orientationDidChangeNotification
    #endif
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.deviceOrientationDidChange),
      name: name,
      object: nil
    )
  }
  open func add(_ toast: Toast) {
    self.queue.addOperation(toast)
  }
  open func cancelAll() {
    queue.cancelAllOperations()
  }
  @objc dynamic func deviceOrientationDidChange() {
    if let lastToast = self.queue.operations.first as? Toast {
      lastToast.view.setNeedsLayout()
    }
  }
}
