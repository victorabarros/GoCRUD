package main

import (
	"fmt"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type User struct {
	Id        uint   `gorm:"column:id"`
	FirstName string `gorm:"column:first_name"`
}

var dsn = "host=localhost user=postgres_user password=postgres_password dbname=postgres_db port=5432 sslmode=disable"

func main() {
	db, err := gorm.Open(postgres.Open(dsn))
	if err != nil {
		panic("failed to connect database")
	}

	var user User
	db.Where("id = ?", 2).First(&user)

	fmt.Printf("%+v\n", user)
}
