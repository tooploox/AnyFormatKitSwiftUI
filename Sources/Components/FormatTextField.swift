//
//  FormatTextField.swift
//  AnyFormatKitSwiftUI
//
//  Created by Oleksandr Orlov on 03.02.2021.
//

import SwiftUI
import AnyFormatKit

@available(iOS 13.0, *)
public struct FormatTextField: UIViewRepresentable {
    
    // MARK: - Typealiases
    
    public typealias UIViewType = UITextField
    
    // MARK: - Data
    
    private let placeholder: String?
    @Binding public var unformattedText: String
    
    // MARK: - Appearence
    
    private var font: UIFont?
    private var textColor: UIColor?
    private var placeholderColor: UIColor?
    private var accentColor: UIColor?
    private var clearButtonMode: UITextField.ViewMode = .never
    private var borderStyle: UITextField.BorderStyle = .none
    private var textAlignment: NSTextAlignment?
    private var keyboardType: UIKeyboardType = .default
    
    // MARK: - Private actions
    
    private var onEditingBeganHandler: TextAction?
    private var onEditingEndHandler: TextAction?
    private var onTextChangeHandler: TextAction?
    private var onClearHandler: VoidAction?
    private var onReturnHandler: VoidAction?
    
    // MARK: - Dependencies
    
    private let formatter: (TextInputFormatter & TextFormatter & TextUnformatter)
    
    // MARK: - Life cycle
    
    public init(unformattedText: Binding<String>,
                placeholder: String? = nil,
                formatter: (TextInputFormatter & TextFormatter & TextUnformatter)
    ) {
        self._unformattedText = unformattedText
        self.placeholder = placeholder
        self.formatter = formatter
    }
    
    /// Will init with DefaultTextInputFormatter
    public init(unformattedText: Binding<String>,
                placeholder: String? = nil,
                textPattern: String,
                patternSymbol: Character = "#") {
        self._unformattedText = unformattedText
        self.placeholder = placeholder
        self.formatter = DefaultTextInputFormatter(textPattern: textPattern, patternSymbol: patternSymbol)
    }
    
    // MARK: - UIViewRepresentable
    
    public func makeUIView(context: Context) -> UIViewType {
        let uiView = UITextField()
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        uiView.adjustsFontForContentSizeCategory = true
        uiView.delegate = context.coordinator
        context.coordinator.formatter = formatter
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        let formattedText = formatter.format(unformattedText)
        if uiView.text != formattedText {
            uiView.text = formattedText
        }
        uiView.textColor = textColor
        uiView.font = font
        updateUIViewPlaceholder(uiView)
        uiView.clearButtonMode = clearButtonMode
        uiView.borderStyle = borderStyle
        uiView.tintColor = accentColor
        uiView.keyboardType = keyboardType
        updateUIViewTextAlignment(uiView)
    }
    
    private func updateUIViewPlaceholder(_ uiView: UIViewType) {
        if let placeholder = placeholder {
            if let placeholderColor = placeholderColor {
                uiView.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: placeholderColor])
            } else {
                uiView.placeholder = placeholder
            }
        } else {
            uiView.placeholder = nil
        }
    }
    
    private func updateUIViewTextAlignment(_ uiView: UIViewType) {
        guard let textAlignment = textAlignment else { return }
        uiView.textAlignment = textAlignment
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(unformattedText: $unformattedText)
        coordinator.onEditingBegan = onEditingBeganHandler
        coordinator.onEditingEnd = onEditingEndHandler
        coordinator.onTextChange = onTextChangeHandler
        coordinator.onClear = onClearHandler
        coordinator.onReturn = onReturnHandler
        return coordinator
    }
    
    // MARK: - View modifiers
    
    public func font(_ font: UIFont?) -> Self {
        var view = self
        view.font = font
        return view
    }
    
    // foregroundColor
    @available(iOS 14.0, *)
    public func foregroundColor(_ color: Color?) -> Self {
        if let color = color {
            return foregroundColor(UIColor(color))
        } else {
            return nilForegroundColor()
        }
    }
    
    public func foregroundColor(_ color: UIColor?) -> Self {
        var view = self
        view.textColor = color
        return view
    }
    
    private func nilForegroundColor() -> Self {
        var view = self
        view.textColor = nil
        return view
    }
    
    // placeholderColor
    public func placeholderColor(_ color: UIColor?) -> Self {
        var view = self
        view.placeholderColor = color
        return view
    }
    
    @available(iOS 14.0, *)
    public func placeholderColor(_ color: Color?) -> Self {
        if let color = color {
            return placeholderColor(UIColor(color))
        } else {
            return nilPlaceholderColor()
        }
    }
    
    private func nilPlaceholderColor() -> Self {
        var view = self
        view.placeholderColor = nil
        return view
    }
    
    // accentColor
    public func accentColor(_ color: UIColor?) -> Self {
        var view = self
        view.accentColor = color
        return view
    }
    
    @available(iOS 14.0, *)
    public func accentColor(_ color: Color?) -> Self {
        if let color = color {
            return accentColor(UIColor(color))
        } else {
            return nilAccentColor()
        }
    }
    
    private func nilAccentColor() -> Self {
        var view = self
        view.accentColor = nil
        return view
    }
    
    // clearButtonMode
    public func clearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        var view = self
        view.clearButtonMode = mode
        return view
    }
    
    // borderStyle
    public func borderStyle(_ style: UITextField.BorderStyle) -> Self {
        var view = self
        view.borderStyle = style
        return view
    }
    
    // textAlignment
    public func textAlignment(_ alignment: TextAlignment) -> Self {
        var view = self
        switch alignment {
        case .leading:
            view.textAlignment = .left
        case .trailing:
            view.textAlignment = .right
        case .center:
            view.textAlignment = .center
        }
        return view
    }
    
    // keyboardType
    public func keyboardType(_ type: UIKeyboardType) -> Self {
        var view = self
        view.keyboardType = type
        return view
    }
    
    // MARK: - Actions
    
    public func onEditingBegan(perform action: TextAction?) -> Self {
        var view = self
        view.onEditingBeganHandler = action
        return view
    }
    
    public func onEditingEnd(perform action: TextAction?) -> Self {
        var view = self
        view.onEditingEndHandler = action
        return view
    }
    
    public func onTextChange(perform action: TextAction?) -> Self {
        var view = self
        view.onTextChangeHandler = action
        return view
    }
    
    public func onClear(perform action: VoidAction?) -> Self {
        var view = self
        view.onClearHandler = action
        return view
    }
    
    public func onReturn(perform action: VoidAction?) -> Self {
        var view = self
        view.onReturnHandler = action
        return view
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate {
        
        let unformattedText: Binding<String>?
        
        var formatter: (TextInputFormatter & TextUnformatter)?
        
        public var onEditingBegan: TextAction?
        public var onEditingEnd: TextAction?
        public var onTextChange: TextAction?
        public var onClear: VoidAction?
        public var onReturn: VoidAction?
        
        init(unformattedText: Binding<String>) {
            self.unformattedText = unformattedText
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let formatter = formatter else { return true }
            let result = formatter.formatInput(
                currentText: textField.text ?? "",
                range: range,
                replacementString: string
            )
            textField.text = result.formattedText
            textField.setCursorLocation(result.caretBeginOffset)
            self.unformattedText?.wrappedValue = formatter.unformat(result.formattedText) ?? ""
            return false
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            onEditingBegan?(textField.text)
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField) {
            onEditingEnd?(textField.text)
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            onEditingEnd?(textField.text)
        }
        
        public func textFieldShouldClear(_ textField: UITextField) -> Bool {
            onClear?()
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.onReturn?()
            return true
        }
    }
}
