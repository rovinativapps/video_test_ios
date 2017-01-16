//
//  ViewController.swift
//  PlayVideos
//
//  Created by Miguel Roncallo on 1/13/17.
//  Copyright © 2017 Nativapps. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController {

    var index = 0
    
    var videoPlayer: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Al aparecer el controlador por primera vez, carga la lista de videos y empieza a descargarlos
        DataService.sharedInstance.getVideoList { (error, list) in
            if  (error != nil){
                print(error!)
            }else{
                    print(list!)
                
                //Se debe bloquear la pantalla con una barra de descarga para realizar la descarga de todos los videos
                DataService.sharedInstance.getVideoFromList(list!,0, { data in
                    //La descarga de los videos finaliza
                })
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Cada vez que va a aparecer el controlador se ejecuta esta función
        self.deleteVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playVideo(_ sender: UIButton) {
     
        // Se crea una ruta para almacenar el video que va a ser visualizado
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writePath = documents.appending("currentVideo.mp4")
        
        
        let fileExists = FileManager.default.fileExists(atPath: writePath)
        
        print(fileExists)
        if !fileExists{
            
            //si el video no existe, se guarda temporalmente en el carrete para poder ser reproducido en la aplicación
            do{
                
                print("trying to save file")
                
                
                //se guarda el video en la ruta especificada

                try DataService.sharedInstance.videoData[self.index].write(to: URL(fileURLWithPath: writePath), options: .atomic)
                
                //url local donde está almacenado el video
                let videoURL = URL(fileURLWithPath: writePath)
                
                //Inicialización del reproductor con la url local
                self.videoPlayer = AVPlayer(url: videoURL)
                
                //inicialización
                let controller = AVPlayerViewController()
                
                controller.player = self.videoPlayer
                
                //Después de ser almacenado el video se reproduce
                
                self.present(controller, animated: true, completion: nil)
                
                self.index += 1
                print("file saved")
            }catch{
                print("error saving file")
                print(error)
            }
            
        }
        
        
        
        
    }

    
    func deleteVideo(){

        //Se borra el video almacenado para evitar que quede en el carrete
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let writePath = documents.appending("currentVideo.mp4")
        do{
            try FileManager.default.removeItem(atPath: writePath)
        }catch{
            print(error)
        }
        
        
    }
    
    func documentsPathForFileName(name: String) -> String {
        
        //función para crear la ruta de almacenamiento del video
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsPath = paths[0]
        return NSURL(fileURLWithPath: documentsPath).appendingPathComponent(name)!.absoluteString
    }
}

