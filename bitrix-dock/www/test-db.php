<?php
// Настройки подключения к серверу
$host = 'mysql';    // Имя сервиса БД из docker-compose
$user = 'root';     // Пользователь (суперпользователь)
$pass = 'root';     // Пароль root
$charset = 'utf8mb4';

// Формируем DSN БЕЗ указания конкретной базы данных (dbname)
$dsn = "mysql:host=$host;charset=$charset";

// Оптимальные настройки PDO
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    // Подключаемся к серверу MySQL
    $pdo = new PDO($dsn, $user, $pass, $options);
    echo "<h3 style='color: green;'>✅ Успешное подключение к серверу MySQL!</h3>";
    
    // 1. Проверяем версию сервера
    $stmt = $pdo->query('SELECT VERSION()');
    $version = $stmt->fetchColumn();
    echo "<p>Версия MySQL: <strong>" . htmlspecialchars($version) . "</strong></p>";

    // 2. Получаем список всех существующих баз данных на сервере
    echo "<h4>Доступные базы данных:</h4>";
    $databases = $pdo->query('SHOW DATABASES')->fetchAll(PDO::FETCH_COLUMN);
    
    echo "<ul>";
    foreach ($databases as $dbName) {
        echo "<li>" . htmlspecialchars($dbName) . "</li>";
    }
    echo "</ul>";

} catch (\PDOException $e) {
    // Вывод ошибки
    echo "<h3 style='color: red;'>❌ Ошибка подключения:</h3>";
    echo "<p><strong>" . htmlspecialchars($e->getMessage()) . "</strong></p>";
}
