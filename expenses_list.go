//Задача 2. Список расходов
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// Функция для добавления новой категории расходов
func addNewCategory(expenses map[string]int, scanner *bufio.Scanner) {
	fmt.Print("Введите название новой категории расходов: ")
	scanner.Scan()
	category := scanner.Text()
	fmt.Print("Введите сумму расходов для этой категории: ")
	scanner.Scan()
	amount, err := strconv.Atoi(scanner.Text())
	if err != nil {
		fmt.Println("Неверный формат суммы. Попробуйте еще раз.")
		return
	}
	expenses[category] = amount
	fmt.Println("Новая категория расходов добавлена.")
}

// Функция для добавления расходов в существующую категорию
func addExpense(expenses map[string]int, scanner *bufio.Scanner) {
	fmt.Print("Введите название категории расходов: ")
	scanner.Scan()
	category := scanner.Text()
	if _, exists := expenses[category]; !exists {
		fmt.Println("Такой категории нет. Попробуйте еще раз.")
		return
	}
	fmt.Print("Введите сумму расходов для этой категории: ")
	scanner.Scan()
	amount, err := strconv.Atoi(scanner.Text())
	if err != nil {
		fmt.Println("Неверный формат суммы. Попробуйте еще раз.")
		return
	}
	expenses[category] += amount
	fmt.Println("Расходы добавлены.")
}

// Функция для вывода всех расходов
func listAllExpenses(expenses map[string]int) {
	if len(expenses) == 0 {
		fmt.Println("Нет записанных расходов.")
		return
	}
	for category, amount := range expenses {
		fmt.Printf("Категория: %s, Сумма: %d\n", category, amount)
	}
}

// Функция для подсчета общей суммы расходов
func calculateTotalExpenses(expenses map[string]int) {
	total := 0
	for _, amount := range expenses {
		total += amount
	}
	fmt.Printf("Общая сумма расходов: %d\n", total)
}

func main() {
	expenses := map[string]int{
		"Продукты":   0,
		"Транспорт":  0,
		"Развлечения": 0,
	}

	fmt.Println("Добро пожаловать в программу подсчета расходов!")
	fmt.Println("Для просмотра всех расходов введите \"all\".")
	fmt.Println("Для добавления нового расхода введите \"add\".")
	fmt.Println("Для добавления новой статьи расходов введите \"new\".")
	fmt.Println("Для подсчета общей суммы расходов введите \"total\".")
	fmt.Println("Для завершения работы введите \"end\".")

	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("Введите команду: ")
		scanner.Scan()
		command := scanner.Text()

		switch strings.ToLower(command) {
		case "all":
			fmt.Println("Список всех расходов:")
			listAllExpenses(expenses)
		case "add":
			addExpense(expenses, scanner)
		case "new":
			addNewCategory(expenses, scanner)
		case "total":
			calculateTotalExpenses(expenses)
		case "end":
			fmt.Println("Работа программы завершена. До свидания!")
			return
		default:
			fmt.Println("Такой команды нет, попробуйте еще раз.")
		}
	}
}
