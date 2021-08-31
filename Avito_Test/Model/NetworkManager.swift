//
//  NetworkManager.swift
//  Avito_Test
//
//  Created by Макс on 30.08.2021.
//

import Foundation


protocol NetworkManagerDelegate{
	func updateData(_ networkManager: NetworkManager, _ taskData: TaskData)
	func handleError(_ error: Error)
}



struct NetworkManager {
	
	var delegate: NetworkManagerDelegate?
	
	
	
	func fetchData() { //запрос данных через URL сессию
		if let url = URL(string: K.link) {
			let session = URLSession(configuration: .default)
		
			let task = session.dataTask(with: url) { data, response, error in
				guard error == nil else { delegate?.handleError(error!); return }
				
				if let data = data {
					if let taskData = self.parseJSON(data: data) {
						delegate?.updateData(self, taskData)
					}
				} else {
					fatalError("no data")
				}
			}
			
			task.resume()
		}
	}
	
	
	
	//парсинг полученного JSON
	private func parseJSON(data: Data) -> TaskData? {
		let decoder = JSONDecoder()
		
		do {
			return try decoder.decode(TaskData.self, from: data)
		} catch {
			delegate?.handleError(error)
			return nil
		}
	}
}
