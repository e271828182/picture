CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build hello.go
docker build -t star/hello .
