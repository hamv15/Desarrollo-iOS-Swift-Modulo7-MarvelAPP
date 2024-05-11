//
//  FavCharViewController.swift
//  MarvelApp
//
//  Created by Hugo Adrián Meza Vega on 08/05/24.
//

import UIKit

class FavCharViewController: UITableViewController {
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //Referencia a la tabla
    @IBOutlet var charatersList: UITableView!
    
    //Recuperar el contexto que se creó
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myFavoriteCharacters: [FavoriteChar] = []
    var charToDelete: FavoriteChar?
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if charatersList.isEditing {
            charatersList.setEditing(false, animated: true)
            sender.title = "Edit"
        }else{
            charatersList.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        charatersList.delegate = self
        charatersList.dataSource = self
        let charManager = CharManager(context: context)
        myFavoriteCharacters = charManager.getAllCharacters()
        charatersList.reloadData()
        //Validar el tamaño de lista para ver si es necesario ocultar el edir
        if myFavoriteCharacters.isEmpty {
            editButton.isHidden = true
        }else{
            editButton.isHidden = false
        }
        
        //Get all characters
        for persistentChar in myFavoriteCharacters{
            print("ID: ", persistentChar.charId ?? "0000", "name: ", persistentChar.name ?? "No name", "description: ",persistentChar.descriptionChar ?? "No description", "resourceURI: ", persistentChar.resourceURI ?? "No resourceURI", "thumbnail: ", persistentChar.thumbnail ?? "No thumbnail")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Actualiza la tabla
            self.tableView.reloadData()
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favCharSegue" {
            let charManager = CharManager(context: context)
            // Validar si el segue apunta a un navigation controller
            if let navigationController = segue.destination as? UINavigationController {
                // Obtener modal de la parte superior del UINavigationController
                if let destination = navigationController.topViewController as? CharSelectedViewController {
                    // Obtener indexPath para extraer el personaje de la lista de consulta principal
                    if let indexPath = self.tableView.indexPathForSelectedRow {
                        let charSelected = charManager.getCharacter(index: indexPath.row)!
                        destination.favCharacter = charSelected
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let charManager = CharManager(context: context)
        return charManager.getAllCharacters().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let charManager = CharManager(context: context)
        if charManager.getAllCharacters().isEmpty {
            editButton.isHidden = true
        }else{
            editButton.isHidden = false
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CharFavoriteCell
        cell?.charName.text = charManager.getCharacter(index: indexPath.row)?.name
        return cell!
    }
    
    //Se atrapa evento de eliminación
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let charManager = CharManager(context: context)
        //Validar confirmación de eleminación
        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure to delete this character?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                // Llama a la acción de confirmación pasada como clausura
                if editingStyle == .delete {
                    
                    //Obtener el char seleccionado de la lista de guardados
                    if let charDelete = charManager.getCharacter(index: indexPath.row) {
                        let result = charManager.deleteCharacter(char: charDelete)
                        if result == true{
                            print("Character was deleted")
                        }else{
                            print("Character was not located!")
                        }
                    }
                    self.tableView.reloadData()
                    if charManager.getAllCharacters().isEmpty {
                        //Cambiar el estado de la edición
                        self.charatersList.setEditing(false, animated: true)
                        self.editButton.title = "Edit"
                        self.editButton.isHidden = true
                    }else{
                        self.editButton.isHidden = false
                    }
                }
            }
            alertController.addAction(confirmAction)
            
            // Presenta el controlador de alerta
            present(alertController, animated: true, completion: nil)
        
        
    }
    
    
}
