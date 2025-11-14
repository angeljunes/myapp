# Documentos MongoDB para la colección cities

## Formato para insertar en MongoDB (MongoDB Shell)

```javascript
// Reemplaza "ID_PAIS_AQUI" con el ObjectId real del país Perú
const PERU_COUNTRY_ID = ObjectId("ID_PAIS_AQUI");

db.cities.insertMany([
  {
    name: "Lima",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Arequipa",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Trujillo",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Chiclayo",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Piura",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Iquitos",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Cusco",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Huancayo",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Tacna",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  },
  {
    name: "Ica",
    createdAt: new Date(),
    country: {
      $ref: "countries",
      $id: PERU_COUNTRY_ID
    }
  }
]);
```

## Formato JSON para MongoDB Compass o herramientas similares

```json
[
  {
    "name": "Lima",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Arequipa",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Trujillo",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Chiclayo",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Piura",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Iquitos",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Cusco",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Huancayo",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Tacna",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  },
  {
    "name": "Ica",
    "createdAt": {"$date": "2024-01-15T00:00:00.000Z"},
    "country": {
      "$ref": "countries",
      "$id": {"$oid": "ID_PAIS_AQUI"}
    }
  }
]
```

## Notas importantes:

1. **Reemplazar ID_PAIS_AQUI**: Debes reemplazar `"ID_PAIS_AQUI"` con el ObjectId real del país Perú en tu base de datos.

2. **ObjectId automático**: MongoDB generará automáticamente el `_id` para cada documento cuando uses `insertMany()` o `insertOne()`.

3. **ISODate**: En MongoDB Shell, `new Date()` crea automáticamente una fecha en formato ISODate. En JSON, se representa como `{"$date": "..."}`.

4. **DBRef**: El formato `{ "$ref": "countries", "$id": ObjectId(...) }` es el formato estándar de DBRef en MongoDB.

## Cómo obtener el ObjectId del país Perú:

```javascript
// En MongoDB Shell, ejecuta:
db.countries.findOne({ name: "Perú" })
// O
db.countries.findOne({ name: "Peru" })

// El resultado mostrará el _id que debes usar
```

