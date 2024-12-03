
import Foundation

class BankAccount {
    let name: String
    var balance: Double
    
    init(name: String, balance: Double) {
        self.name = name
        self.balance = balance
    }
    
    func deposit(amount: Double) {
        balance += amount
    }
    
    func transfer(amount: Double, to account: BankAccount) {
        guard balance >= amount else { return }
        balance -= amount
        account.deposit(amount: amount)
    }
}

nonisolated(unsafe) let cuentaPaca = BankAccount(name: "Paca Antonia Furnieles", balance: 35000)
nonisolated(unsafe) let cuentaAntonio = BankAccount(name: "Antonio Segismundo Beniatrez", balance: 45000)

cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)
cuentaPaca.transfer(amount: 100, to: cuentaAntonio)
cuentaAntonio.transfer(amount: 100, to: cuentaPaca)

cuentaPaca.balance
cuentaAntonio.balance

// Provocando un DATA RACE

DispatchQueue.global().async {
    for _ in 1...100 {
        cuentaPaca.transfer(amount: 10, to: cuentaAntonio)
    }
}

DispatchQueue.global().async {
    for _ in 1...100 {
        cuentaAntonio.transfer(amount: 10, to: cuentaPaca)
    }
}

sleep(12)

cuentaPaca.balance
cuentaAntonio.balance


// Solución un DATA RACE

DispatchQueue.global().async {
    Task { @MainActor in
        for _ in 1...100 {
            cuentaPaca.transfer(amount: 10, to: cuentaAntonio)
        }
    }
}

DispatchQueue.global().async {
    Task { @MainActor in
        for _ in 1...100 {
            cuentaAntonio.transfer(amount: 10, to: cuentaPaca)
        }
    }
}

sleep(10)

cuentaPaca.balance
cuentaAntonio.balance
