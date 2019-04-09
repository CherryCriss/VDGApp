import Foundation
public protocol PinCodeTextFieldDelegate: class {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool 
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) 
    func textFieldValueChanged(_ textField: PinCodeTextField) 
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool 
    func textFieldDidEndEditing(_ textField: PinCodeTextField) 
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool 
}
public extension PinCodeTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
    }
    func textFieldValueChanged(_ textField: PinCodeTextField) {
    }
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: PinCodeTextField) {
    }
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}
