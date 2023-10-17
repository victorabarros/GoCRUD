package main

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type User struct {
	Id        int    `gorm:"column:id"         json:"id"`
	FirstName string `gorm:"column:first_name" json:"first_name"`
}

var dsn = "host=localhost user=postgres_user password=postgres_password dbname=postgres_db port=5432 sslmode=disable" //todo move to config https://github.com/ardanlabs/service/blob/b483f8b09c9feed037e2342dce6a345050481f21/app/services/sales-api/v1/cmd/cmd.go#L142C15-L142C15
var db *gorm.DB

func main() {
	g := gin.Default()

	//todo move to internal/database ; create a Configure function
	var err error
	db, err = gorm.Open(postgres.Open(dsn))
	if err != nil {
		panic("failed to connect database")
	}

	SetRoutes(g)

	g.Run()
}

func SetRoutes(g *gin.Engine) {
	//TODO move to internal/router
	// g.GET("/user/:id", GetUser)
	g.Handle(http.MethodGet, "/user/:id", GetUser)
	g.Handle(http.MethodGet, "/ping", func(ctx *gin.Context) {
		ctx.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})
}

func GetUser(ctx *gin.Context) {
	//todo move to internal/services/user
	param := ctx.Param("id")
	id, err := strconv.Atoi(param)
	if err != nil {
		resp := gin.H{"message": fmt.Sprintf("can't parse '%s' to integer", param)}
		ctx.JSON(http.StatusBadRequest, resp)
		return
	}

	//todo move to internal/repositories/user
	var user User
	db.Where("id = ?", id).First(&user)

	if user.Id != id {
		resp := gin.H{"message": fmt.Sprintf("user id '%s' not found", param)}
		ctx.JSON(http.StatusBadRequest, resp)
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"user": user})
}
