//
//  ViewController.swift
//  MarvelApp
//
//  Created by Rafael González on 30/04/24.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var charSelected: Character?
    
    var keyLoader = KeyLoader.shared
    
    var characterManager : CharacterServiceManager?

    @IBOutlet weak var characterCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //print(keyLoader.getAPIParams())
        //print(keyLoader.getQueryString())
        
        characterCollectionView.delegate = self
        characterCollectionView.dataSource = self
        
        characterManager = CharacterServiceManager()
        characterManager?.loadCharacterData(queryString: keyLoader.getQueryString(limit: Constants.numberOfItemsRequested, offset: 0)){
            print(self.keyLoader.getQueryString(limit: Constants.numberOfItemsRequested, offset: 0))
            //Objto que maneja la ejecución de tareas en un hio de ejecución principal
            DispatchQueue.main.async {
                //Para que funcione de manera asincrona
                //Ejecuta la actualización de la interfaz
                print("Completion executed!!")
                self.characterCollectionView.reloadData()
                //ajustar el offset
                self.characterManager?.offset = (self.characterManager?.countCharacter())!
            }
            
        }
        
    }
    
    //Método para mandar datos al controlador de char Selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            // Validar si el segue apunta a un UINavigationController
            if let navigationController = segue.destination as? UINavigationController {
                // Obtener la referencia del UINavigationController hacia charSelected
                if let destination = navigationController.topViewController as? CharSelectedViewController {
                    // Obtener indexPath para recuperar el character de la consulta principal
                    if let indexPath = self.characterCollectionView.indexPathsForSelectedItems?.first {
                        charSelected = characterManager?.getCharacter(at: indexPath.row)
                        destination.detailCharacter = charSelected
                    }
                }
            }
        }
    }

}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (characterManager?.countCharacter())!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CharacterCell
        
        cell.characterName.text = characterManager?.getCharacter(at: indexPath.row).name
        let urlImage = URL(string: (characterManager?.getCharacter(at: indexPath.row).thumbnail.url)!)
        //cell.characterImage.image = UIImage(named: "ccc")
        //Implementar descarga de imagen a través del paquete SDWEBIMAGE
        cell.characterImage.sd_setImage(with: urlImage)
        
        return cell
    }
    
}

//Con este método se identifica las coordenadas del scroll
extension ViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //        size of scrollview content
        //        print("contentSize.height", scrollView.contentSize.height)
        //        screen's available space for scrollview element
        //        print("bounds.height:", scrollView.bounds.height)
        //        contentOffset y = contentSize.height - bounds.height
        //        print("contentOffset y:", scrollView.contentOffset.y)
                
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollviewHeight = scrollView.bounds.height
        
        if (offsetY > (contentHeight - scrollviewHeight)) && (!characterManager!.maxItemLoaded && !characterManager!.isLoading ){
            print("calling API...")
            self.characterManager!.isLoading = true
            let queryString = keyLoader.getQueryString(limit: Constants.numberOfItemsRequested, offset: self.characterManager!.offset)
                print("qs:",queryString)
            
            self.characterManager!.loadCharacterData(queryString: queryString){
                DispatchQueue.main.async {
                    self.characterCollectionView.reloadData()
//                    print("char com:",self.characterManager!.countCharacter())
//                    print("actual offset: ", self.characterManager!.offset)
                    self.characterManager!.offset = self.characterManager!.countCharacter()
                    //print("new offset: ", self.characterManager!.offset)
                    self.characterManager!.isLoading = false
                }
            }
        }
//        else{
//            print("Don't call API...")
//        }
    }
}
