//
//  DataService.swift
//  PlayVideos
//
//  Created by Miguel Roncallo on 1/13/17.
//  Copyright © 2017 Nativapps. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class DataService{
    static let sharedInstance = DataService()
    var videoData = [Data]()

    let baseUrl = "http://media.myvitale.com"
    
    func getVideoList(_ cb: @escaping (NSError?, [String]?)->()){
        
        //Traer la lista con los nombres de los videos para descargarlos
        
        let urlString =  URL(string: "\(baseUrl)/list_exers.json")
        
        Alamofire.request(urlString!).validate().responseJSON(completionHandler: {
            response in
            
            switch response.result{
            case .success:
                if let value = response.result.value{
                    let json = JSON(value)
                    
                    var listing = [String]()
                    for  (_,subJson):(String, JSON) in json{
//                        print(subJson)
                        let string = "\(subJson["vid_id"].stringValue).mp4"
                        listing.append(string)
                    }
                    
                    //espera a que la lista termine de almacenar los nombres en un array para continuar
                    
                    cb(nil, listing)

                }
                
            case .failure(let error):
                print(error.localizedDescription)
                cb(error as NSError!, nil)
            }
            
        })
    }
    
    func getVideoFromList(_ list: [String],_ index: Int, _ cb: @escaping (NSError?, [Data]?)->()){
        //Función recursiva para descargar los videos
        //recibe la lista de los nombres de los videos a descargar
        
        print("list count")
        print(list.count)
        
        
        if index < list.count{
            //recorre la lista de los nombres de los videos
            print("Index: \(index)")
            let urlString = URL(string: "\(baseUrl)/\(list[index])")
            Alamofire.request(urlString!).responseData { response in
                debugPrint("All Response Info: \(response)")
                
                switch response.result{
                case .success:
                    print("success")
                    print(response.result.value)
                    if let data = response.result.value{
                        self.videoData.append(data)
                        print("Calling again")
                        //almacena el video descargado como datos
                        
                        //vuelve a llamarse para descargar el próximo video en la lista
                        self.getVideoFromList(list, index+1, { (error,data) in
                            cb(error, data)
                        })
                    }
                    
                    
                    
                case .failure(let error):
                    cb(error as NSError!, nil)
                }
                
            }
            
        }else{
            
            //regresa la lista de los videos en forma de Data
            cb(nil, videoData)
        }
        
        print("Video count")
        print(videoData.count)
    }
}
