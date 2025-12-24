$login = Invoke-RestMethod -Method POST "http://127.0.0.1:8000/api/auth/login" `
  -ContentType "application/json; charset=utf-8" `
  -Body ([System.Text.Encoding]::UTF8.GetBytes('{"email":"test@example.com","password":"12345678"}'))

$token = $login.access

$cats = Invoke-RestMethod -Method GET "http://127.0.0.1:8000/api/categories?type=expense" `
  -Headers @{ Authorization = "Bearer $token" }

$catId = $cats[0].id

$body = @{
  month = "2025-12"
  categoryId = $catId
  limitAmount = 100000
  alertThreshold = 80
} | ConvertTo-Json

Invoke-RestMethod -Method POST "http://127.0.0.1:8000/api/budgets" `
  -Headers @{ Authorization = "Bearer $token" } `
  -ContentType "application/json; charset=utf-8" `
  -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
