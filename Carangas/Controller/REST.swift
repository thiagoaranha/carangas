//
//  REST.swift
//  Carangas
//
//  Created by Thiago on 03/08/2018.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation
import Alamofire

enum RESTOperation {
    case save
    case update
    case delete
}

class REST{
    
    private static let basePath = "https://carangas.herokuapp.com/car"
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 10.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    // session criada automaticamente e disponivel para reusar
    //private static let session = URLSession(configuration: configuration) // URLSession.shared
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        
        Alamofire.request(url).responseJSON { response in
            
            guard response.result.isSuccess else {
                onError(.noResponse)
                return
            }
            
            if let data = response.data {
                
                do {
                    let brands = try JSONDecoder().decode([Car].self, from: data)
                    onComplete(brands)
                    return
                } catch {
                    onError(.noData)
                }
            }else{
                onError(.noData)
                return
            }
            
        }
        
        // tarefa criada, mas nao processada
        /*let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                    
                }
                if response.statusCode == 200 {
                    
                    // obter o valor de data
                    guard let data = data else {
                        onError(.noData)
                        return
                    }
                    
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                        // pronto para reter dados
                        
                        for car in cars {
                            print(car.name)
                        }
                        
                    } catch {
                        // algum erro ocorreu com os dados
                         onError(.invalidJSON)
                    }
                    
                } else {
                    onError(.responseStatusCode(code: response.statusCode))
                }
            } else {
                onError(.taskError(error: error!))
            }
        }
        // start request
        dataTask.resume()*/
        
    }
    
    class func save(car: Car, onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void ) {
         applyOperation(car: car, operation: .save, onComplete: onComplete, onError: onError)
    }
    
    class func update(car: Car, onComplete: @escaping (Bool) -> Void , onError: @escaping (CarError) -> Void) {
        // chamando o update passando operation
        applyOperation(car: car, operation: .update, onComplete: onComplete, onError: onError)
        
    }
    
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void , onError: @escaping (CarError) -> Void) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete, onError: onError)
    }
    
    private class func applyOperation(car: Car, operation: RESTOperation , onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void) {
        
        let urlString = basePath + "/" + (car._id ?? "")
        
        guard let url = URL(string: urlString) else{
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        var httpMethod: String = ""
        
        switch operation {
        case .delete:
            httpMethod = "DELETE"
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
        }
        
        // transformar objeto para um JSON, processo contrario do decoder -> Encoder
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request.httpMethod = httpMethod
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        
        Alamofire.request(request).responseJSON { response in
            
            switch response.result {
            case .success:
                print("Validation Successful")
                onComplete(true)
            case .failure(let error):
                onError(.noData)
                return
            }
            
            
        }
        
        
        /*let dataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                // verificar e desembrulhar em uma unica vez
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else {
                    onComplete(false)
                    return
                }
                
                // ok
                onComplete(true)
                
            } else {
                onComplete(false)
            }
        }
        
        dataTask.resume()*/
        
    }
    
    // o metodo pode retornar um array de nil se tiver algum erro
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void) {
        
        // URL TABELA FIPE
        let urlFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
        
        guard let url = URL(string: urlFipe) else {
            onComplete(nil)
            return
        }
        
        Alamofire.request(url).responseJSON { response in
            
            guard response.result.isSuccess else {
                onComplete(nil)
                return
            }

            if let data = response.data {
                
                do {
                    let brands = try JSONDecoder().decode([Brand].self, from: data)
                    onComplete(brands)
                    return
                } catch {
                    onComplete(nil)
                }
            }else{
                onComplete(nil)
                return
            }
            
        }
        
        // tarefa criada, mas nao processada
        /*let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil)
                    return
                }
                if response.statusCode == 200 {
                    // obter o valor de data
                    guard let data = data else {
                        onComplete(nil)
                        return
                    }
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                        // algum erro ocorreu com os dados
                        onComplete(nil)
                    }
                } else {
                    onComplete(nil)
                }
            } else {
                onComplete(nil)
            }
        }
        // start request
        dataTask.resume()*/
    }
    
}


