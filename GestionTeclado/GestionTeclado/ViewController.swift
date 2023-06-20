//
//  ViewController.swift
//  GestionTeclado
//
//  Created by estech on 9/1/23.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ocultar teclado
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture) //el view de ambos es la vista completa
        
        //Definir delegados de los text fields
        for textField in view.textFieldsInView {
            textField.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Registrar observadores para detectar cuándo se muestra y oculta el teclado
        NotificationCenter.default.addObserver(self, selector: #selector(mostrarTeclado), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ocultarTeclado), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Eliminar observadores
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Pasar al siguiente textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //Con @objc permitimos que la func se llame por Objective C
    @objc func mostrarTeclado(notification: NSNotification) {
        print("Se va a mostrar el teclado")
        
        //Para que el contenido suba cuando salga el teclado
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let seleccionado = view.selectedTextField {
                if seleccionado.frame.origin.y + seleccionado.frame.height > UIScreen.main.bounds.size.height - keyboardSize.height { // - 100
                    //El teclado tapa el textField seleccionado
                    if self.view.frame.origin.y == 0 { //Comprobar que no esté ya movido
                        self.view.frame.origin.y -= keyboardSize.height
                    }
                }
            }
        }
    }
    
    @objc func ocultarTeclado(notification: NSNotification) {
        print("Se va a ocultar el teclado")
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}

//Obtener el textField que se está editando
extension UIView {
    var textFieldsInView: [UITextField] {
        return subviews
            .filter({ !($0 is UITextField) })
            .reduce((subviews.compactMap { $0 as? UITextField }), { summ, current in
                return summ + current.textFieldsInView
            })
    }
    
    var selectedTextField: UITextField? {
        return textFieldsInView.filter { $0.isFirstResponder }.first
    }
}
