protocol CustomAlertViewDelegate: class {
    func okButtonTapped(selectedOption: String, textFieldValue: String)
    func cancelButtonTapped()
}
