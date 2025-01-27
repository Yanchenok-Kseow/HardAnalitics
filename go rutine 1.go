package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"sync"
)

func wordCount(input chan string, output chan int, wg *sync.WaitGroup) {
	defer wg.Done()
	for line := range input {
		words := strings.Fields(line)
		output <- len(words)
	}
}

func main() {
	input := make(chan string)
	output := make(chan int)
	var wg sync.WaitGroup

	// Запускаем несколько горутин для обработки строк
	for i := 0; i < 3; i++ {
		wg.Add(1)
		go wordCount(input, output, &wg)
	}

	// Отправляем строки в канал из стандартного ввода
	go func() {
		scanner := bufio.NewScanner(os.Stdin)
		fmt.Println("Введите строки для подсчета слов (для завершения введите пустую строку):")
		for scanner.Scan() {
			line := scanner.Text()
			if line == "" {
				break
			}
			input <- line
		}
		close(input)
	}()

	// Закрываем канал output после завершения всех горутин
	go func() {
		wg.Wait()
		close(output)
	}()

	// Собираем результаты
	var results []int
	for count := range output {
		results = append(results, count)
	}

	// Выводим результаты
	fmt.Println("Результат:")
	for _, count := range results {
		fmt.Printf("Word count: %d\n", count)
	}
}




