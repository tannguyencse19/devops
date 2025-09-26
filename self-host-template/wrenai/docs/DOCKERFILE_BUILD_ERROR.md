# Symptomps

-.json:48,47-59: Unknown variable; There is no variable named "WREN_UI_PORT"., and 1 other diagnostic(s)

# Root cause

- Dockerfile build can't handle this specification in `.env`

```
WREN_UI_PORT=3000
WREN_UI_ENDPOINT=http://wren-ui:${WREN_UI_PORT}
```

Have to explicit like this

```
WREN_UI_ENDPOINT=http://wren-ui:3000
```
