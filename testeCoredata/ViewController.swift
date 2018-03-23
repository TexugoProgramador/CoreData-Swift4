//
//  ViewController.swift
//  testeCoredata
//
//  Created by Humberto Puccinelli on 01/03/2018.
//  Copyright © 2018 Humberto Puccinelli. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var botaoAdd: UIBarButtonItem!
    @IBOutlet weak var tabelaNomes: UITableView!
    
    var pessoas:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabelaNomes.dataSource = self
        tabelaNomes.delegate = self
        
        recarregaDados()
        title = "Tabela Nomes"
        tabelaNomes.register(UITableViewCell.self, forCellReuseIdentifier: "celula")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pessoas.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celulaTabela = tableView.dequeueReusableCell(withIdentifier: "celula", for:indexPath)
        let pessoa = pessoas[indexPath.row]
        
        celulaTabela.textLabel?.text = pessoa.value(forKey: "nome") as? String
        
        return celulaTabela
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deletarNome(pessoaDeletar: pessoas[indexPath.row])
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var nomePessoa = ""
        nomePessoa = pessoas[indexPath.row].value(forKey: "nome") as! String
        
        let alerta = UIAlertController(title: "Editar nome",
                                       message: nomePessoa,
                                       preferredStyle: .alert)
        
        let salvarNovoNome = UIAlertAction(title: "salvar",
                                           style: .default) {
                                            [unowned self] action in
                                            
                                            guard let textField = alerta.textFields?.first,  let nomeSalvar = textField.text else {
                                                
                                                return
                                            }
                                            self.updateNomes(pessoaUpade: self.pessoas[indexPath.row], nome: nomeSalvar)
        }
        
        let cancelar = UIAlertAction(title: "cancelar", style: .default)
        
        alerta.addTextField()
        
        alerta.addAction(salvarNovoNome)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true)
        
    }
    
    func recarregaDados() -> Void {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pessoas")
        
        do {
            pessoas = try managedContext.fetch(fetchRequest)
            tabelaNomes.reloadData()
        } catch let error as NSError {
            print("Dados não encontrados \(error), \(error.userInfo)")
        }
    }
    
    func salvarNovoNome(nome: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pessoas", in: managedContext)!
        let pessoa = NSManagedObject(entity: entity,  insertInto: managedContext)
        
        pessoa.setValue(nome, forKeyPath: "nome")
        
        do {
            try managedContext.save()
            pessoas.append(pessoa)
        } catch let error as NSError {
            print("Não foi possível salvar erro. \(error), \(error.userInfo)")
        }
    }
    
    func updateNomes(pessoaUpade: NSManagedObject, nome: String) -> Void {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        pessoaUpade.setValue(nome, forKey: "nome")
        
        do{
            try managedContext.save()
            
            let alerta = UIAlertController(title: "Sucesso", message: "dados atualizados", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alerta.addAction(ok)
            present(alerta, animated: true)
            
            recarregaDados()
            
        }catch{
            let alerta = UIAlertController(title: "Erro",  message: "erro ao atualizar dados", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default)
            alerta.addAction(ok)
            present(alerta, animated: true)
        }
        
        
    }
    
    func deletarNome(pessoaDeletar: NSManagedObject) -> Void {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(pessoaDeletar)
        
        do{
            try managedContext.save()
            
            let alerta = UIAlertController(title: "Sucesso", message: "pessoa deletada com sucesso", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alerta.addAction(ok)
            present(alerta, animated: true)
            
            recarregaDados()
            
        }catch{
            let alerta = UIAlertController(title: "Erro",  message: "erro ao deletar Pessoa", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default)
            alerta.addAction(ok)
            present(alerta, animated: true)
            
        }
    }
    
    @IBAction func addNome(_ sender: UIBarButtonItem) {
        
        let alerta = UIAlertController(title: "Novo nome",
                                       message: "Add novo nome",
                                       preferredStyle: .alert)
        
        let salvarNovoNome = UIAlertAction(title: "salvar",
                                           style: .default) {
                                            [unowned self] action in
                                            
                                            guard let textField = alerta.textFields?.first,
                                                let nomeSalvar = textField.text else {
                                                    return
                                            }
                                            
                                            self.salvarNovoNome(nome: nomeSalvar)
                                            self.tabelaNomes.reloadData()
        }
        
        let cancelar = UIAlertAction(title: "cancelar", style: .default)
        
        alerta.addTextField()
        
        alerta.addAction(salvarNovoNome)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true)
        
    }
    
}
