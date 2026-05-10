# Protocol

All communication happens over WebSockets (ws://<IP>:8765).
Data format is JSON.

## Slider Update
```json
{
  "type": "slider",
  "id": 1,
  "value": 45
}
```
*Value range: -90 to 90*

## Text Message
```json
{
  "type": "text",
  "value": "hello"
}
```

## Command
```json
{
  "type": "command",
  "value": "set"
}
```
