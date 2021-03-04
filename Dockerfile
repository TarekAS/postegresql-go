FROM golang:1.15-alpine as builder

# Install git and ca-certificates (for SSL).
RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

# Create user without credentials.
RUN adduser \
  --disabled-password \
  --gecos "" \
  --home "/nonexistent" \
  --shell "/sbin/nologin" \
  --no-create-home \
  --uid 10001 \
  "appuser"
WORKDIR $GOPATH/src/mypackage/myapp/
COPY . .

# Get dependencies.
RUN go get -v -d

# Fully static Go build.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
  -ldflags='-w -s -extldflags "-static"' -a \
  -o /go/bin/app .


# Build tiny image.
FROM scratch

# Copy users, groups, certificates, timezone info, and our program.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /go/bin/app /go/bin/app

# Switch to non-root user.
USER appuser:appuser

# Run the app.
ENTRYPOINT ["/go/bin/app"]
