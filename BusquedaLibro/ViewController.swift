//
//  ViewController.swift
//  BusquedaLibro
//
//  Created by Rodrigo on 04/12/16.
//  Copyright © 2016 Rodrigo Hernandez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputISBN: UITextField!
    
    @IBOutlet weak var txtResultISBN: UITextView!
    
    // Estado de la peticion: { true:exitoso, false:error }
    var resultRequest:Bool = false
    
    // Respuesta de la peticion
    var responseRequest:String = ""
    
    
    @IBAction func actionSearch(sender: AnyObject) {
        self.searchISBN(inputISBN.text!)
        //self.mostrarResultado()
        
    }
    
    @IBAction func actionClean(sender: AnyObject) {
        print("Limpiar...")
        self.inputISBN.text = ""
        self.txtResultISBN.text = ""
        self.resultRequest = false
        self.responseRequest = ""
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addToolBar(inputISBN)
        inputISBN.returnKeyType = UIReturnKeyType.Search
        inputISBN.keyboardAppearance=UIKeyboardAppearance.Alert
        inputISBN.clearButtonMode = UITextFieldViewMode.Always // .WhileEditing  .Never
        
        
        inputISBN.placeholder = NSLocalizedString("ISBN...", comment: "El formato debe ser del tipo 999-99-999-9999-9")
        inputISBN.autocorrectionType = .No
        
        inputISBN.tintColor = UIColor.blueColor()
        inputISBN.textColor = UIColor.brownColor()
        
        inputISBN.layer.cornerRadius = 6.0
        inputISBN.layer.masksToBounds = true
        inputISBN.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.99)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == inputISBN {
            textField.resignFirstResponder() // Close keyboard
            searchISBN(textField.text!)
            return true
        }
        else{
            textField.resignFirstResponder()
            return false
        }
    }

    func searchISBN(codISBN:String){
        print("Buscando libro por ISBN:"+codISBN+" ...")
        self.resultRequest = false
        
        if !codISBN.isEmpty {
            self.txtResultISBN.text = ""
            self.responseRequest = ""
            
            // Peticion / Request - INI
            let strURL = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"+codISBN
            let url = NSURL(string: strURL)
            let sesion = NSURLSession.sharedSession()

            let bloque1Asyncronico = { (datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
                if error == nil {
                    let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
                    print("result: ->"+(texto! as String))
                    let resultRequest:String = (texto as? String)!
                    if !resultRequest.isEmpty {
                        self.responseRequest = resultRequest
                        self.resultRequest = true
                        let bloque2Asyncronico = {
                            if self.responseRequest == "{}" {
                                print("No se encontraron datos para el ISBN ingresado por el usuario")
                                // Mostrar Alert - INI
                                let alert = UIAlertController(title: "Sin informacion",
                                                          message: "No hay información disponible para el ISBN ingresado",
                                                          preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "Aceptar", style: .Cancel, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                                // Mostrar Alert - FIN
                            }
                            else{
                                self.txtResultISBN.text = self.responseRequest
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), bloque2Asyncronico )
                    }
                    else{
                        print("El servicio de consulta de ISBN no está disponible")
                        // Mostrar Alert - INI
                        let alert = UIAlertController(title: "Sin servicio",
                                                      message: "El servicio de consulta de ISBN no está disponible",
                                                      preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .Cancel, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        // Mostrar Alert - FIN
                    }
                }
                else{
                    print("ocurrio un error durante el envio de la peticion")
                    // Mostrar Alert - INI
                    let alert = UIAlertController(title: "Resultado",
                                                  message: "Ocurrió un error durante el envío de la petición",
                                                  preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    // Mostrar Alert - FIN
                }
            }
            let dt = sesion.dataTaskWithURL(url!, completionHandler: bloque1Asyncronico)
            dt.resume()
            print("peticion asincronica iniciada")
            // Peticion / Request - FIN
            
            
        }
        else{
            print("campo ISBN esta vacio")
            // Mostrar Alert - INI
            let alert = UIAlertController(title: "Validación",
                                          message: "Por favor ingrese un ISBN no vacío",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            // Mostrar Alert - FIN
        }

    }
    
}

extension UIViewController: UITextFieldDelegate{
    
    func addToolBar(textField: UITextField){
        
        var toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        
        var labDone:String = "\u{000021E4}Limpiar"
        
        // var buttonDone = UIBarButtonItem(title: labDone, style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
        
        var buttonDone = UIBarButtonItem(title: labDone, style: UIBarButtonItemStyle.Plain, target: self, action: "cleanPressed")
        
        var labCancel:String = "\u{0000274E}Cerrar"
        var buttonCancel = UIBarButtonItem (title: labCancel, style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPressed")
        
        var buttonSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([buttonCancel, buttonSpace, buttonDone], animated: false)
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    func cleanPressed(){
        //view.endEditing(true)
        for view in self.view.subviews {
            if let textField = view as? UITextField {
                if textField.restorationIdentifier == "IDinputISBN" {
                    print(textField.text!)
                    // Limpiar su valor
                    textField.text = ""
                }
                
            }
        }
    }
    
    
    func donePressed(){
        view.endEditing(true)
    }
    
    
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
}
