//
//  CharSelectedViewController.swift
//  MarvelApp
//
//  Created by Hugo Adrián Meza Vega on 10/05/24.
//

import UIKit
import SDWebImage
import CoreData
import SafariServices

class CharSelectedViewController: UIViewController {
    
    //Recuperar el contexto que se creó
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var detailCharacter: Character?
    var favCharacter: FavoriteChar?
    var indexCharacterSend = -1
    
    //Colocar el nombre, imagen y descripción
    
    @IBOutlet weak var characterName: UILabel!
    
    @IBOutlet weak var characterImage: UIImageView!
    
    @IBOutlet weak var characterDescription: UILabel!
    
    //Referencia al boton de agregar para poder ocultarlo
    @IBOutlet weak var saveCharButton: UIBarButtonItem!
    
    
    @IBOutlet weak var referenceSourceTV: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if detailCharacter != nil{
            //Provienes del controlador principal
            saveCharButton.isHidden=false
            
            //Precargar los datos el character seleccionado
            characterName.text = detailCharacter?.name
            characterDescription.text = (detailCharacter?.description != nil && detailCharacter?.description != "") ? detailCharacter?.description : "NO DESCRPTION."
            
            let urlImage = URL(string: (detailCharacter?.thumbnail.url)!)
            //Implementar descarga de imagen a través del paquete SDWEBIMAGE
            characterImage.sd_setImage(with: urlImage)
            
            //Colocar link hipervinculo
            // Configura el texto con el enlace hiperactivo
            let text = "Reference resource (Click here)."
            let url = URL(string: "https://developer.marvel.com/documentation/generalinfo")!
            referenceSourceTV.attributedText = configureHyperlinkText(text: text, linkURL: url)
            
            // Configura la detección de enlaces hiperactivos
            referenceSourceTV.isUserInteractionEnabled = true
            referenceSourceTV.isSelectable = true
            
            // Agrega un gesto de toque para detectar el toque en el enlace hiperactivo
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLink))
            referenceSourceTV.addGestureRecognizer(tapGesture)
            
        }else if favCharacter != nil{
            saveCharButton.isHidden=true
            //Setter data
            characterName.text = favCharacter?.name
            characterDescription.text = (favCharacter?.descriptionChar != nil && favCharacter?.descriptionChar != "") ? favCharacter?.descriptionChar : "NO DESCRPTION."
            let urlImage = URL(string: (favCharacter?.thumbnail)!)
            characterImage.sd_setImage(with: urlImage)
            //Colocar hipervinculo
            // Configura el texto con el enlace hiperactivo
            let text = "Reference resource (Click here)."
            let url = URL(string: (favCharacter?.resourceURI)!)!
            referenceSourceTV.attributedText = configureHyperlinkText(text: text, linkURL: url)
            
            // Configuración de la detección de enlaces hiperactivos
            referenceSourceTV.isUserInteractionEnabled = true
            referenceSourceTV.isSelectable = true
            
            // Detectar el toque en el enlace hiperactivo
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLink))
            referenceSourceTV.addGestureRecognizer(tapGesture)
        }else{
            saveCharButton.isHidden=true
            //Mostrar alerta de error
            showAlert(message: "Data couldn't be loaded.")
        }
        
        
    }
    
    @objc func openLink(_ sender: UITapGestureRecognizer) {
            guard let textView = sender.view as? UITextView else { return }
            
            // Obtener la ubicación del toque en el texto
            let layoutManager = textView.layoutManager
            var location = sender.location(in: textView)
            location.x -= textView.textContainerInset.left
            location.y -= textView.textContainerInset.top
            
            // Obtener la posición del carácter en el texto
            let characterIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            // Verificar si el carácter en la ubicación del toque es un enlace
            if let url = textView.attributedText.attribute(.link, at: characterIndex, effectiveRange: nil) as? URL {
                // Abre el enlace en un SFSafariViewController
                openLinkInSafari(url: url)
            }
        }
    
    func configureHyperlinkText(text: String, linkURL: URL) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: text.count)
        attributedString.addAttribute(.link, value: linkURL, range: range)
        return attributedString
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func addFavCharTapped(_ sender: UIBarButtonItem) {
        //Agregar datos y almacenar en BD
        //Create charManager
        let charManager = CharManager(context: context)
        //Antes de agregar, validar la existencia del character
        if let _ = charManager.getCharacterByName(name: detailCharacter!.name){
            showAlert(message: "This character already exists in your favorite list.")
        }else{
            let charSaved = charManager.createChar(charId: UUID(), name: detailCharacter!.name, descriptionChar: detailCharacter!.description, resourceURI: "https://developer.marvel.com/documentation/generalinfo", thumbnail: detailCharacter!.thumbnail.url)
            if charSaved != nil {
                dismiss(animated: true, completion: nil)
            }else{
                showAlert(message: "Error saving character.")
            }
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}


extension UIViewController {
    func openLinkInSafari(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}

