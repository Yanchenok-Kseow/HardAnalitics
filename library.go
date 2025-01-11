package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// Структура для представления книги
type Book struct {
	Title  string
	Author string
	Year   int
	Status string
}

// Структура для представления библиотеки
type Library struct {
	Books []Book
}

// Метод для добавления новой книги в библиотеку
func (lib *Library) AddBook(title, author string, year int) {
	book := Book{Title: title, Author: author, Year: year, Status: "доступна"}
	lib.Books = append(lib.Books, book)
}

// Метод для выдачи книги читателю
func (lib *Library) IssueBook(title string) bool {
	for i := range lib.Books {
		if strings.ToLower(lib.Books[i].Title) == strings.ToLower(title) && lib.Books[i].Status == "доступна" {
			lib.Books[i].Status = "на руках у читателя"
			return true
		}
	}
	return false
}

// Метод для возврата книги в библиотеку
func (lib *Library) ReturnBook(title string) bool {
	for i := range lib.Books {
		if strings.ToLower(lib.Books[i].Title) == strings.ToLower(title) && lib.Books[i].Status == "на руках у читателя" {
			lib.Books[i].Status = "доступна"
			return true
		}
	}
	return false
}

// Функция для поиска книги по названию
func (lib *Library) SearchBook(title string) (Book, bool) {
	for _, book := range lib.Books {
		if strings.ToLower(book.Title) == strings.ToLower(title) {
			return book, true
		}
	}
	return Book{}, false
}

// Функция для вывода списка всех книг
func (lib *Library) ListBooks() {
	for _, book := range lib.Books {
		fmt.Printf("Название: %s, Автор: %s, Год: %d, Статус: %s\n", book.Title, book.Author, book.Year, book.Status)
	}
}

// Функция для вывода списка доступных книг
func (lib *Library) ListAvailableBooks() {
	for _, book := range lib.Books {
		if book.Status == "доступна" {
			fmt.Printf("Название: %s, Автор: %s, Год: %d, Статус: %s\n", book.Title, book.Author, book.Year, book.Status)
		}
	}
}

// Функция для поиска книги по части названия
func (lib *Library) FindBook(query string) bool {
	found := false
	for _, book := range lib.Books {
		if strings.Contains(strings.ToLower(book.Title), strings.ToLower(query)) {
			fmt.Printf("Название: %s, Автор: %s, Год: %d, Статус: %s\n", book.Title, book.Author, book.Year, book.Status)
			found = true
		}
	}
	return found
}

func main() {
	lib := Library{}

	// Добавление книг в библиотеку
	lib.AddBook("Преступление и наказание", "Достаевский Ф.М.", 1866)
	lib.AddBook("Анна Каренина", "Толстой Л.Н.", 1877)
	lib.AddBook("Мастер и Маргарита", "Булгаков М.А", 1967)

	fmt.Println("Добро пожаловать в библиотеку!")
	fmt.Println("Для просмотра всего списка книг введите \"all\".")
	fmt.Println("Для просмотра доступных книг введите \"free\".")
	fmt.Println("Для того, чтобы взять книгу, введите \"take\".")
	fmt.Println("Для возврата книги введите \"return\".")
	fmt.Println("Для добавления книги введите \"add\".")
	fmt.Println("Чтобы найти книгу введите \"find\".")
	fmt.Println("Для завершения работы введите \"end\".")


	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("Введите команду: ")
		scanner.Scan()
		command := scanner.Text()

		switch strings.ToLower(command) {
		case "all":
			fmt.Println("Список всех книг:")
			lib.ListBooks()
		case "free":
			fmt.Println("Список доступных книг:")
			lib.ListAvailableBooks()
		case "take":
			fmt.Print("Введите название книги, которую хотите взять: ")
			scanner.Scan()
			title := scanner.Text()
			if lib.IssueBook(title) {
				fmt.Println("Книга выдана.")
			} else {
				fmt.Println("Книга не может быть выдана.")
			}
		case "return":
			fmt.Print("Введите название книги, которую хотите вернуть: ")
			scanner.Scan()
			title := scanner.Text()
			if lib.ReturnBook(title) {
				fmt.Println("Книга возвращена.")
			} else {
				fmt.Println("Книга не может быть возвращена.")
			}
		case "add":
			fmt.Print("Введите название книги: ")
			scanner.Scan()
			title := scanner.Text()
			fmt.Print("Введите автора книги: ")
			scanner.Scan()
			author := scanner.Text()
			fmt.Print("Введите год издания книги: ")
			scanner.Scan()
			var year int
			fmt.Sscanf(scanner.Text(), "%d", &year)
			lib.AddBook(title, author, year)
			fmt.Println("Книга добавлена.")
		case "end":
			fmt.Println("Работа библиотеки завершена. До свидания!")
			return
		case "find":
			fmt.Print("Введите название книги или часть названия: ")
			scanner.Scan()
			query := scanner.Text()
			if lib.FindBook(query) {
				fmt.Println("Книга найдена.")
			} else {
				fmt.Println("Такой книги нет.")
			}
		default:
			fmt.Println("Такой команды нет, попробуйте еще раз.")
		}
	}
}