//
//  ViewController.swift
//  Avito_Test
//
//  Created by Макс on 29.08.2021.
//

import UIKit


class ViewController: UIViewController {

	//MARK: - атрибуты
	@IBOutlet weak var tableView: UITableView! //основная таблица
	
	var networkManager = NetworkManager() //функционал запроса данных
	var taskData: TaskData? //полученные данные
	
	
	
	//MARK: - методы
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//подпишем себя в tableView
		tableView.dataSource = self
		tableView.delegate = self
		tableView.tag = -1
		
		networkManager.delegate = self //подпишем себя к функционалу запроса данных
		networkManager.fetchData() //и запросим данные с ресурса
		
		//подпишем метод перерисовки данных на событие изменения ориентации
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
	}

	
	@objc func orientationDidChange() { //перерисовка данных после изменения ориентации
		tableView.reloadData()
	}
	
	
	func numberOfSections(in tableView: UITableView) -> Int { //кол-во секций (компаний)
		return 1 //в этой версии данных всего одна компания
	}


	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		//непосредственно перед отрисовкой ячейки главной таблицы подпишем себя во вложенную таблицу
		//присвоем ей метку TAG и дернем заполнение данными, иначе они сломаются при смене ориентации
		if let cell = cell as? TableViewCell {
			cell.skillsTableView.dataSource = self
			cell.skillsTableView.delegate = self
			cell.skillsTableView.tag = indexPath.row
			
			cell.skillsTableView.reloadData()
		}
	}
	
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let data = taskData {
			if tableView.tag == -1 {
				return K.cellHeightFixed + K.cellHeight * CGFloat( data.company.employees[indexPath.row].skills.count )
			}
			else {
				return K.cellHeight
			}
		}
		return 0
	}
}



//заголовок секции
extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let data = taskData, tableView.tag == -1 else { return nil }
		
		return "\(data.company.name)"
	}
}



//MARK: - заполнение данными
extension ViewController: UITableViewDataSource {
	
	//количество строк
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let data = taskData else { return 0 }
		
		if tableView.tag == -1 { //для главной таблицы
			return data.company.employees.count
		} else { //для вложенных таблиц
			return data.company.employees[tableView.tag].skills.count
		}
	}
	
	
	//данные в ячейках
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let data = taskData else { return UITableViewCell() }
		
		if tableView.tag == -1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: K.cellID, for: indexPath) as! TableViewCell
			cell.nameLabel.text = data.company.employees[indexPath.row].name
			cell.phoneLabel.text = data.company.employees[indexPath.row].phone_number
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: K.skillsCellID, for: indexPath) as! SkillsTableViewCell
			cell.skillLabel.text = data.company.employees[tableView.tag].skills[indexPath.row]
			
			return cell
		}
	}
}



//MARK: - получение данных
extension ViewController: NetworkManagerDelegate {
	
	func updateData(_ networkManager: NetworkManager, _ taskData: TaskData) {
		var taskDataSorted = taskData
		taskDataSorted.company.employees.sort { empl, empl2 in
			return empl.name < empl2.name
		}
		
		DispatchQueue.main.async {
			self.taskData = taskDataSorted
			self.tableView.reloadData()
		}
	}
	
	func handleError(_ error: Error) {
		DispatchQueue.main.async {
			print(error)
			self.present(UIAlertController(title: "Sorry!", message: "Something went wrong, try again later!", preferredStyle: .alert), animated: true)
		}
	}
}
