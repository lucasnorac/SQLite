//
//  ViewController.swift
//  SQLite
//
//  Created by Lucas Caron Albarello on 03/01/2018.
//  Copyright © 2018 Lucas Caron Albarello. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    var database : Connection!
    let userTable = Table("users")
    let id = Expression<Int>("id")
    let nome = Expression<String>("nome")
    let email = Expression<String>("email")
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
    }
    @IBAction func createTable(_ sender: UIButton) {
        let createTable = self.userTable.create {(table) in
            table.column(self.id, primaryKey: true)
            table.column(self.nome)
            table.column(self.email, unique: true)
        }
        do {
          try self.database.run(createTable)
            print("Create Table")
        } catch{
            print(error)
        }
        
    }
    
    @IBAction func insertUser(_ sender: UIButton) {
        let alert = UIAlertController(title: "Escreva seu nome e email", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Nome"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        let action = UIAlertAction(title: "Salvar", style: .default) { (_) in
            guard let nome = alert.textFields?.first?.text,
            let email = alert.textFields?.last?.text else {return}
            let insertUser = self.userTable.insert(self.nome <- nome, self.email <- email)
            do {
                try self.database.run(insertUser)
                print("Usuario Inserts")
            }catch{
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ListUser(_ sender: UIButton) {
        do {
            let users = try self.database.prepare(userTable)
            for user in users {
                print("userId: \(user[self.id]), nome: \(user[self.nome]), email: \(user[self.email])")
            }
        } catch{
            print(error)
        }
    }
    
    @IBAction func UpdateUser(_ sender: UIButton) {
        let alert = UIAlertController(title: "Atualize seu nome ou email", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Usuario Id"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "Email"
        }
        let action = UIAlertAction(title: "Atualizar", style: .default) { (_) in
            guard let userIdStrings = alert.textFields?.first?.text,
                let userId = Int(userIdStrings),
                let email = alert.textFields?.last?.text else {return}
            print(userId)
            print(email)
                let user = self.userTable.filter(self.id == userId)
                let updateUser = self.userTable.update(self.email <- email)
            do{
               try self.database.run(updateUser)
            }catch{
                print(error)
            }
            print("Atualizado")
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteUser(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete seu nome ou email", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Usuario Id"
        }
        let action = UIAlertAction(title: "Deletar", style: .default) { (_) in
            guard let userIdStrings = alert.textFields?.first?.text,
                let userId = Int(userIdStrings) else {return}
            print(userId)
        let user = self.userTable.filter(self.id == userId)
        let delete = self.userTable.delete()
            do {
                try self.database.run(delete)
            }catch{
                print(error)
            }
        
    }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
}

}
