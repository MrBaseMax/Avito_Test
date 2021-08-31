//
//  TaskData.swift
//  Avito_Test
//
//  Created by Макс on 30.08.2021.
//

import Foundation


struct TaskData: Decodable {
	var company: Company //в данном примере одна компания, но сделал задел на массив
}

struct Company: Decodable {
	let name: String
	var employees: [Employee]
}

struct Employee: Decodable {
	let name: String
	let phone_number: String
	let skills: [String]
}

