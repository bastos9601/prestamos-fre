<?php
// Configuración de conexión PostgreSQL
// Base de datos: PrestamosEdin
// Migración desde MySQL a PostgreSQL

// Leer variables de entorno con valores por defecto
$host = getenv('DB_HOST') ?: 'localhost';
$user = getenv('DB_USER') ?: 'postgres';
$password = getenv('DB_PASSWORD') ?: 'solsolperez';
$database = getenv('DB_NAME') ?: 'PrestamosEdin';
$port = getenv('DB_PORT') ?: 5432;

// Soporte para DATABASE_URL (postgres://user:pass@host:port/dbname)
$databaseUrl = getenv('DATABASE_URL');
if ($databaseUrl) {
    $url = parse_url($databaseUrl);
    if ($url) {
        $host = $url['host'] ?? $host;
        $port = $url['port'] ?? $port;
        $user = $url['user'] ?? $user;
        $password = $url['pass'] ?? $password;
        $database = isset($url['path']) ? ltrim($url['path'], '/') : $database;
    }
}

try {
    // Crear conexión PDO para PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    // Permitir SSL si está configurado
    if (getenv('DB_SSLMODE')) {
        $dsn .= ";sslmode=" . getenv('DB_SSLMODE');
    }

    $conn = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    
    // Configurar zona horaria
    $conn->exec("SET timezone = 'America/Lima'");
    
} catch (PDOException $e) {
    die('Conexión fallida: ' . $e->getMessage());
}
?>