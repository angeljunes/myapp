// Script MongoDB para insertar ciudades de Perú
// Uso: mongo "mongodb+srv://edgarangelja_db_user:M3TEIlEqdGh2eT09@cluster0.iwfms3i.mongodb.net/?appName=Cluster0" mongodb_cities_insert.js
// O reemplaza ID_PAIS_AQUI con el ObjectId real del país Perú

// ObjectId del país Perú
const PERU_COUNTRY_ID = ObjectId("507f1f77bcf86cd799439021");

const cities = [
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
];

// Insertar en la colección cities
db.cities.insertMany(cities);

print(`Se insertaron ${cities.length} ciudades de Perú exitosamente.`);

