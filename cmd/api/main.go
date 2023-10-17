package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type User struct {
	Id        uint   `gorm:"column:id"         json:"id"`
	FirstName string `gorm:"column:first_name" json:"first_name"`
}

var dsn = "host=localhost user=postgres_user password=postgres_password dbname=postgres_db port=5432 sslmode=disable"

func main() {
	db, err := gorm.Open(postgres.Open(dsn))
	if err != nil {
		panic("failed to connect database")
	}

	g := gin.Default()
	g.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	g.GET("/", func(c *gin.Context) {
		var user User
		db.Where("id = ?", 2).First(&user)

		fmt.Printf("%+v\n", user)

		c.JSON(http.StatusOK, gin.H{
			"data": user,
		})
	})

	g.Run()
}
